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

### Changed

- `implement`, `pr`, and `review-pr` keep comments in the code they write or
  suggest to a minimum: the code explains itself, and a comment says only what
  the code cannot, such as why the obvious way is wrong. The rule lives in
  `plugins/dev-skills/references/code-comments.md`.

## [1.0.0] - 2026-10-22

First release.

### Added

- `dev-skills` plugin:
  - `research` — investigates the task (an idea, a feature, a problem) before
    anything is planned, and writes `research.md` into a case of the knowledge
    base. Questions about how the existing code works go to
    `research-codebase`.
  - `research-codebase` — answers a question about the existing code in the
    chat, with file and line references, and saves the answer to
    `docs/codebase/<topic>.md` when asked. It works across several
    repositories, starts from what `docs/codebase/` already holds, and splits a
    broad question between subagents with a shared brief that keeps their areas
    apart.
    - Saved answers go into the folder Claude was started in, never into the
      researched repository's tracked files; inside a repository the folder is
      listed in the personal `.git/info/exclude`, never in `.gitignore`.
    - Estimates, risks, and recommended order are given only when asked, in an
      "Assessment" section apart from the facts.
    - Facts from outside the code carry a URL or are marked as unverified
      general knowledge; counts are re-run or labelled as a subagent's.
    - It says which branch and commit it read, and compares with the default
      branch when they differ.
    - A follow-up question on the same subject is merged into the same saved
      file.
  - `plan` — turns the research into a scoped plan, split into phases with
    success criteria, and writes it as `plan.md` into the case. It takes
    research from the case, from `docs/codebase/` notes and from the
    conversation, and picks or creates the case on its own when none is
    active.
    - The plan is written in the user's language, and every file of the run
      (`case.md` included) uses the same one.
    - The template fits upgrades and migrations as well as features: use cases
      and requirements have a variant per kind of work, and the plan opens with
      a header (date, repositories, base branch, commits, inputs) and "Prior
      work", and ends with "Next Step".
    - Each phase states its dependencies, size, outward actions, and rollback,
      and splits manual checks into "before merge" and "after rollout", marking
      the checks that need an open pull request. Checks that repeat are written
      once under "Common checks", phases that follow one recipe go into a
      table, and each phase label keeps one wording throughout the plan.
    - Open questions say who answers them and which phase they block; none may
      block Phase 1, and anything a search can answer is looked up instead.
    - Before handing over, the plan's cited lines are re-checked and the cheap,
      read-only commands in its criteria are run once.
  - `implement` — implements the active case's plan one phase at a time, runs
    the phase's checks, and pauses for manual verification.
    - Each phase that changes code starts on its own new branch, named for the
      phase, from an up-to-date base in the plan's repository. A branch whose
      pull request is merged or closed is never reused, and uncommitted work is
      never stashed or discarded.
    - A phase runs in a fixed order: implement, run the checks that need no
      pull request, ask, hand off to `pr`, run the checks that need the open
      pull request (CI, a label, an approval), then pause for manual
      verification. The "after rollout" checks follow the merge and are carried
      in every report until the user confirms them.
    - It asks before every outward action a phase lists and follows the
      phases' dependencies.
    - It reads plans in any language: it recognizes a phase's parts
      (dependencies, automated and manual checks, common checks, phase tables)
      by what they say, never by their labels in any language. A manual list
      that does not say whether it is for before the merge or after the rollout
      counts as before the merge.
    - Before it picks a phase, it compares the plan's checkboxes, the card's
      `Outcome`, and the phases' pull requests, and asks when they disagree, so
      work done outside the skill is not redone.
  - `architecture` — documents, reviews, or proposes an architecture in the
    case's `architecture.md`.
  - `data-model` — documents, reviews, or redesigns a data model in the case's
    `data-model.md`.
  - `pr` — commits the change, pushes the branch, and opens or updates a pull
    request described as motivation, what was done, and how to verify, then
    records the pull request, outcome, and lessons in the case card.
    - It does this only on the user's own request. A question it asked and the
      user has not answered is not permission.
    - It never merges, not even when asked inside the skill: it may create a
      working branch, commit, push, and open or update the pull request, and
      the merge is left to the user. It also never enables auto-merge or a
      merge queue.
    - For a plan with phases, the card's `Outcome` keeps one line per phase and
      the case stays `in-progress` until the last phase: `pr` sets `in-review`
      only for the last phase's pull request, and `solved` waits for every
      phase.
  - `review-pr` — reviews a pull request and shows the user every finding
    before anything reaches it.
    - It reads the changed files of logic in full and fixtures, generated code,
      and lockfiles by size and search, the callers and consumers of what
      changed, the CI checks, and the reviews and comments already on the pull
      request, and follows the repository's own review instructions. It checks
      what the base branch gained since the merge base and whether the pull
      request still merges cleanly, and runs the tests on the merge result,
      without a commit, when the base changed the same modules or the build
      files they inherit.
    - It checks the tests against the task, not against CI: each requirement
      is mapped to the test that proves it, expected values must come from the
      task rather than the code's own output, tests bent to pass (assertions
      that always hold, mocks that return what is asserted, skipped tests,
      raised timeouts, unexplained changes to existing expectations) are
      findings, and the core requirement is broken in a temporary worktree,
      where the pull request wires it in, to see the tests fail.
    - It checks the description's claims against the code, rollout and
      recovery steps included.
    - Every finding is verified, cites a file and line, describes a concrete
      case where the code goes wrong, and is marked `CONFIRMED` or
      `PLAUSIBLE`.
    - Every finding shows its code the way a GitHub review comment does: the
      lines with a few lines of context and their numbers at the head commit,
      with the lines the pull request changed marked. `scripts/excerpt.sh`
      prints them from git, says whether they can carry an inline comment, and
      stops with an error on a range that is not in the file. An excerpt is
      never edited or cut; it is kept short by choosing the range.
    - Before it shows the findings, it checks the pull request's head and CI
      again; when the head moved during the review, a force-push included, it
      re-checks the findings against the new head and says what changed.
      Points already raised are credited, not repeated; problems that predate
      the pull request are listed apart.
    - The findings come back in the chat in the language of the user's
      request, headings and labels included, with a draft comment each in the
      pull request's language, and are saved in English as `review-pr-<n>.md`
      in a knowledge-base case, so one case can hold the reviews of several
      pull requests. Each review file starts with a fixed line naming the pull
      request, the round, the head, and the merge base.
    - A later round reviews only what changed since the previous one,
      re-checks each earlier finding as fixed, still open, answered, or
      obsolete, and is saved as `review-pr-<n>-round-<k>.md`; the case card
      keeps only the latest state. A merged or closed pull request is reviewed
      only when the user confirms.
    - On the user's own pull request each finding carries a fix instead of a
      draft comment, nothing is posted, and fixing is left to `pr` on the
      user's word.
    - It posts nothing until the user has read the findings and chosen what to
      post, and then only as a pending review the user submits. It never
      approves, requests changes, or resolves a thread, and it never touches
      the user's checkout.
  - `draft-message` — drafts a work message for the user to send themselves:
    questions to a product owner, a status update to a manager, a test
    handoff, a request to a colleague. It takes the recipient (name, role, or
    relation) and the channel (email, chat, ticket or pull request comment) and
    shapes the length and tone to both.
    - It returns the text in the chat and never sends, posts, or saves it, not
      even when asked inside the skill.
    - The text is written to read as the user's own. The skill describes the
      habits that give machine-written text away (typography, empty openers and
      closers, inflated words, sentence patterns, document layout) by what they
      do rather than as word lists, so the rules hold in any language, and
      every draft goes through a check against them.
    - It uses only facts from the conversation and the sources the user points
      to, and names the gaps instead of inventing them.
    - It also starts when the user asks for a message in plain words.
- A shared knowledge base for all skills. They read and write the `docs/`
  folder of the folder Claude was started in, outside any repository's tracked
  files, organized in cases: one folder per subject under `docs/cases/`, with a
  short `case.md` card (status, services, exact error texts, outcome, lessons)
  next to the research and the plan. `scripts/reindex.sh` rebuilds
  `docs/INDEX.md` from the cards. Every skill starts by searching it and
  reports "Prior work", so a problem solved in one service is found when it
  turns up in another. The index is searched first and read in full only when
  the search finds nothing or it is short.
- `phase-gate` plugin: an optional `PreToolUse` hook that blocks source edits
  until the case's plan is approved. It is opt-in per folder, through a
  `.claude-phase-gate` marker. Approval is `echo <case slug> > docs/.approved`,
  checked against `docs/.active` and the case's research and plan; Claude is
  blocked from writing `docs/.approved` at all times, also after approval.

[Unreleased]: https://github.com/vnovakovskyi/claude-dev-skills/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vnovakovskyi/claude-dev-skills/releases/tag/v1.0.0
