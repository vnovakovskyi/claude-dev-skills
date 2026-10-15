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
