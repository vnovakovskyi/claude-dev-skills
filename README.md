# Claude Dev Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A [Claude Code](https://code.claude.com) plugin that makes Claude research and
plan before it writes code, and then turns the finished work into a pull request.

```text
research → plan → implement → pr
```

Each step is a command. `research` and `plan` write a document into your
project's `docs/` folder, so you can read it, correct it, and decide when to move
on. `implement` then builds the plan one phase at a time.

## Install

In a Claude Code session:

```text
/plugin marketplace add vnovakovskyi/claude-dev-skills
/plugin install dev-skills@novakovskyi-dev-skills
```

Type `/` and the commands appear as `/dev-skills:research`, `/dev-skills:plan`,
and so on. The plugin adds skills only: no hooks, no servers.

From a shell, the same two commands start with `claude plugin` instead of
`/plugin`. Once installed, the plugin is also there in the desktop app and the
VS Code extension on the same machine.

## Stay up to date

You keep the version you installed until you update it. Pick one of two ways
not to miss a release.

**Turn on auto-update (recommended).** Run `/plugin`, open the **Marketplaces**
tab, select `novakovskyi-dev-skills`, and choose **Enable auto-update**. Claude
Code then fetches new versions on its own and tells you when one is ready.

**Or watch the releases.** On the
[repository page](https://github.com/vnovakovskyi/claude-dev-skills), click
**Watch → Custom → Releases**. GitHub emails you when a version comes out, and
you update by hand:

```bash
claude plugin marketplace update novakovskyi-dev-skills
claude plugin update dev-skills@novakovskyi-dev-skills
```

Then start a new session, or run `/reload-plugins` in an open one.

`claude plugin list` shows the version you have, and
[CHANGELOG.md](CHANGELOG.md) says what changed in each one.

Want a change before it is released? See
[docs/unreleased.md](docs/unreleased.md).

## Skills

| Command | What it does | Writes |
|---|---|---|
| `/dev-skills:research` | Investigates an idea, a feature, a problem, or an existing codebase before anything is planned. | `docs/00-research.md` |
| `/dev-skills:plan` | Turns the research into a scoped plan, split into small phases with success criteria. | `docs/01-plan.md` |
| `/dev-skills:implement` | Implements one phase of the plan, runs its checks, and pauses for your verification. | code |
| `/dev-skills:architecture` | Optional. Documents, reviews, or proposes an architecture. | `docs/02-architecture.md` |
| `/dev-skills:data-model` | Optional. Documents, reviews, or redesigns a data model. | `docs/03-data-model.md` |
| `/dev-skills:pr` | Commits the change, pushes the branch, and opens or updates the pull request. | the pull request |

The first five run only when you type the command. `pr` also starts when you ask
for a pull request in plain words.

## How to use it

Run Claude Code inside your project:

```text
/dev-skills:research <idea, feature, problem, or codebase area to research>
/dev-skills:plan <what should be planned>
/dev-skills:implement
/dev-skills:pr
```

`research` and `plan` never write code. `implement` does one phase of the plan,
runs that phase's checks, and waits for you before it starts the next one. The
step from planning to coding is always yours to take.

`pr` describes the work in three parts — motivation, what was done, how to
verify — and never credits an AI tool in the commits or in the pull request. It
targets the default branch; name another one to target that instead, for example
`/dev-skills:pr dev`. A branch that does not exist yet is created.

The details are in [docs/workflow.md](docs/workflow.md).

## Optional: a hard gate

The pauses above are instructions that Claude follows. If you want source edits
to be blocked for real until you approve the plan, install the second plugin:

```text
/plugin install phase-gate@novakovskyi-dev-skills
```

It is a hook, it needs `jq`, and it does nothing until you opt a project in. See
[docs/phase-gate.md](docs/phase-gate.md).

## Uninstall

```text
/plugin marketplace remove novakovskyi-dev-skills
```

This removes the marketplace and both plugins. Files the skills wrote into your
projects are left untouched.

## More

- [docs/workflow.md](docs/workflow.md) — how the workflow keeps Claude from
  coding too early, and what each skill writes
- [docs/phase-gate.md](docs/phase-gate.md) — the optional hard gate
- [docs/unreleased.md](docs/unreleased.md) — running `dev`, a branch, or your
  own clone before a release
- [CHANGELOG.md](CHANGELOG.md) — what changed in each version
- [CONTRIBUTING.md](CONTRIBUTING.md) — how to propose a change
- [claude-writer-skills](https://github.com/vnovakovskyi/claude-writer-skills) —
  sibling skills for reviewing articles and drafts

## License

Licensed under the [MIT License](LICENSE): free to use, copy, modify, and
distribute for any purpose, including commercial use. © 2026 Vadym Novakovskyi.
