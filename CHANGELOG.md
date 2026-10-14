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
  `docs/codebase/<topic>.md` when asked.

### Changed

- `research` is about the task now, not about explaining the code: it reads
  `docs/codebase/` for context and points to `research-codebase` for questions
  about how the code works.

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
