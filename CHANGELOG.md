# Changelog

All notable changes to the plugins in this repository are recorded here. Both
plugins, `dev-skills` and `phase-gate`, share one version number.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
the versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **Major:** a change that breaks a habit — a skill renamed or removed, a
  different output file or format.
- **Minor:** a new skill or a new capability.
- **Patch:** wording, examples, fixes.

To see which version you have installed, run `claude plugin list`.

## [Unreleased]

### Added

- `review-pr` — reviews someone's pull request and shows the user every finding
  before anything reaches it.
  - It reads the changed files in full, the callers and consumers of what
    changed, the CI checks, and the reviews and comments already on the pull
    request, and follows the repository's own review instructions.
  - It checks the description's claims against the code, rollout and recovery
    steps included.
  - Every finding is verified, cites a file and line, describes a concrete case
    where the code goes wrong, and is marked `CONFIRMED` or `PLAUSIBLE`.
  - Every finding shows its code the way a GitHub review comment does: the
    lines with a few lines of context and their numbers at the head commit,
    with the lines the pull request changed marked. `scripts/excerpt.sh` prints
    them from git, says whether they can carry an inline comment, and stops
    with an error on a range that is not in the file.
  - Before it shows the findings, it checks the pull request's head and CI
    again; when the head moved during the review, a force-push included, it
    re-checks the findings against the new head and says what changed. Points
    already raised are credited, not repeated; problems that predate the pull
    request are listed apart.
  - The findings come back in the chat with a draft comment each and are saved
    as `review.md` in a knowledge-base case. A later round compares with the
    previous one.
  - It posts nothing until the user has read the findings and chosen what to
    post, and then only as a pending review the user submits. It never
    approves, requests changes, or resolves a thread, and it never touches the
    user's checkout.

- `draft-message` — drafts a work message for the user to send themselves:
  questions to a product owner, a status update to a manager, a test handoff,
  a request to a colleague. It takes the recipient (name, role, or relation)
  and the channel (email, chat, ticket or pull request comment) and shapes the
  length and tone to both.
  - It returns the text in the chat and never sends, posts, or saves it, not
    even when asked inside the skill.
  - The text is written to read as the user's own. The skill describes the
    habits that give machine-written text away (typography, empty openers and
    closers, inflated words, sentence patterns, document layout) by what they
    do rather than as word lists, so the rules hold in any language, and every
    draft goes through a check against them.
  - It uses only facts from the conversation and the sources the user points
    to, and names the gaps instead of inventing them.
  - It also starts when the user asks for a message in plain words.

- `research-codebase` — answers a question about the existing code in the chat,
  with file and line references, and saves the answer to
  `docs/codebase/<topic>.md` when asked. It works across several repositories,
  starts from what `docs/codebase/` already holds, and splits a broad question
  between subagents with a shared brief that keeps their areas apart.
  - Saved answers go into the folder Claude was started in, never into the
    researched repository's tracked files; inside a repository the folder is
    listed in the personal `.git/info/exclude`, never in `.gitignore`.
  - Estimates, risks, and recommended order are given only when asked, in an
    "Assessment" section apart from the facts.
  - Facts from outside the code carry a URL or are marked as unverified general
    knowledge; counts are re-run or labelled as a subagent's.
  - It says which branch and commit it read, and compares with the default
    branch when they differ.
  - A follow-up question on the same subject is merged into the same saved file.

- A shared knowledge base. All skills read and write the `docs/` folder of the
  folder Claude was started in, organized in cases: one folder per subject
  under `docs/cases/`, with a short `case.md` card (status, services, exact
  error texts, outcome, lessons) next to the research and the plan.
  `scripts/reindex.sh` rebuilds `docs/INDEX.md` from the cards. Every skill
  starts by searching it and reports "Prior work", so a problem solved in one
  service is found when it turns up in another.

### Changed

- `plan` takes research from `docs/codebase/` notes and from the conversation,
  not only from a case's `research.md`, and writes it into the case. It picks
  or creates the case on its own when none is active.
  - The plan is written in the user's language, and every file of the run
    (`case.md` included) uses the same one.
  - The template fits upgrades and migrations as well as features: use cases
    and requirements have a variant per kind of work, overlapping sections were
    merged, and the plan opens with a header (date, repositories, commits,
    inputs), "Prior work", and ends with "Next Step".
  - Each phase states its dependencies, size, outward actions, and rollback,
    and splits manual checks into "before merge" and "after rollout". Checks
    that repeat are written once under "Common checks", and phases that follow
    one recipe go into a table.
  - Open questions say who answers them and which phase they block; none may
    block Phase 1, and anything a search can answer is looked up instead.
  - Before handing over, the plan's cited lines are re-checked and the cheap,
    read-only commands in its criteria are run once.
- `implement` asks before every outward action a phase lists, follows the
  phases' dependencies, reads checkboxes in phase tables, and treats a phase as
  done once its "before merge" checks pass, carrying the "after rollout" ones
  in every report until the user confirms them.
- **Breaking:** the skills no longer write `docs/00-research.md`,
  `docs/01-plan.md`, `docs/02-architecture.md`, or `docs/03-data-model.md` into
  the project. They write `research.md`, `plan.md`, `architecture.md`, and
  `data-model.md` into a case of the knowledge base, outside any repository's
  tracked files. `implement` reads the active case's plan; `pr` records the
  pull request, outcome, and lessons in the card.
- **Breaking:** `phase-gate` approves per case. Approval is
  `echo <case slug> > docs/.approved`, checked against `docs/.active` and the
  case's research and plan; `.claude-phase-approved` is no longer read. Claude
  is blocked from writing `docs/.approved` at all times, also after approval.
- `research` is about the task now, not about explaining the code: it points
  to `research-codebase` for questions about how the code works.
- `pr` commits, pushes, and opens a pull request only on the user's own
  request. A question it asked and the user has not answered is not
  permission.
- `pr` never merges, not even when asked inside the skill: it may create a
  working branch, commit, push, and open or update the pull request, and the
  merge is left to the user. It also never enables auto-merge or a merge
  queue.

## [1.0.0] - 2026-10-11

First release.

### Added

- `dev-skills` plugin:
  - `research` — investigates an idea, feature, problem, or codebase and writes
    `docs/00-research.md`.
  - `plan` — turns the research into a phased plan in `docs/01-plan.md`.
  - `implement` — implements one phase of the plan at a time and pauses for
    manual verification.
  - `architecture` — documents, reviews, or proposes an architecture in
    `docs/02-architecture.md`.
  - `data-model` — documents, reviews, or redesigns a data model in
    `docs/03-data-model.md`.
  - `pr` — commits the change, pushes the branch, and opens or updates a pull
    request described as motivation, what was done, and how to verify.
- `phase-gate` plugin: an optional `PreToolUse` hook that blocks source edits in
  opted-in projects until the plan is approved.

[Unreleased]: https://github.com/vnovakovskyi/claude-dev-skills/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vnovakovskyi/claude-dev-skills/releases/tag/v1.0.0
