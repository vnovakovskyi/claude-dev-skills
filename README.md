# Claude Dev Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A [Claude Code](https://code.claude.com) plugin with skills for a development
workflow in which Claude researches and plans before it writes code.

```text
research → plan → implement → pr
```

Each of the first three steps writes a document into your project's `docs/`
folder. You read it, correct it, and decide when to move on. Two optional skills,
`architecture` and `data-model`, cover design questions that deserve a document
of their own. The last step, `pr`, turns the finished work into a pull request.

Skills for reviewing articles and drafts live in a separate repository:
[claude-writer-skills](https://github.com/vnovakovskyi/claude-writer-skills).

## Skills

| Command | What it does | Writes |
|---|---|---|
| `/dev-skills:research` | Investigates an idea, feature, problem, or existing codebase. Separates facts from assumptions, lists risks and open questions, and recommends the next step. | `docs/00-research.md` |
| `/dev-skills:plan` | Turns the research into a scoped plan split into small phases, each with automated and manual success criteria and an explicit "Out of Scope". | `docs/01-plan.md` |
| `/dev-skills:implement` | Implements one phase of the plan, runs its automated checks, ticks its checkboxes, then pauses for your manual verification. | code, and the checkboxes in `docs/01-plan.md` |
| `/dev-skills:architecture` | Optional. Documents, reviews, or proposes the architecture of a new idea or an existing service, with ADR-style decisions. | `docs/02-architecture.md` |
| `/dev-skills:data-model` | Optional. Documents, reviews, or redesigns the domain and data model: schemas, constraints, indexes, migrations, data flows. | `docs/03-data-model.md` |
| `/dev-skills:pr` | Commits what belongs to the change, pushes the branch, and opens or updates a pull request described in three parts: motivation, what was done, how to verify. | commits, and the pull request |

Every command carries the plugin's name. Short names such as `plan` or
`research` are easy to collide with, both with built-in commands and with other
skills you have installed. The `dev-skills:` prefix rules that out.

The five workflow skills run only when you type the command. Claude never starts
them on its own (`disable-model-invocation: true`). `pr` also starts when you ask
for a pull request in plain words.

Use `architecture` or `data-model` whenever they help:

- After research, before planning.
- Inside an existing service, to document or review its current architecture.
- Inside an existing service, to review or redesign its data model.
- Before a migration or a refactoring.

## How the workflow keeps Claude from coding too early

This repo uses a **soft, conversational gate** — no hook, no marker files in the
normal flow. The discipline lives in the skills themselves:

- `plan` produces a **phased plan** in `docs/01-plan.md`. Each phase has its own
  **Automated** and **Manual** success-criteria checkboxes, plus an explicit
  "Out of Scope". `plan` never writes code — it ends by asking you to review and
  then run `/dev-skills:implement`.
- `implement` does **one phase at a time**. It implements the phase, runs that
  phase's automated checks, ticks the `- [x]` boxes in the plan, and then
  **pauses and waits for you** to confirm manual verification before the next
  phase.

So approval is a normal conversational act (you choose to run
`/dev-skills:implement`, and you confirm between phases) — there is no approval
file to create, forget, or delete. Progress is tracked by the checkboxes inside
`docs/01-plan.md`, so work is resumable: re-running `/dev-skills:implement`
picks up at the first unchecked phase.

> If you also want **hard** enforcement — where Claude is *physically* blocked
> from editing code until you approve — there is an optional second plugin. See
> [Optional: hard enforcement gate](#optional-hard-enforcement-gate).

## Install

The repository is a plugin marketplace with two plugins: `dev-skills` (the six
skills) and the optional `phase-gate`. In a Claude Code session, add the
marketplace once and install the skills:

```text
/plugin marketplace add vnovakovskyi/claude-dev-skills
/plugin install dev-skills@vnovakovskyi-dev-skills
```

The same from your shell, without starting a session:

```bash
claude plugin marketplace add vnovakovskyi/claude-dev-skills
claude plugin install dev-skills@vnovakovskyi-dev-skills
```

Then type `/` in a session: the commands appear as `/dev-skills:research`,
`/dev-skills:plan`, and so on.

Installing `dev-skills` adds skills only. It registers no hooks and starts no
servers.

## Usage

Run Claude Code inside your project and start with the main line:

```text
/dev-skills:research <idea, feature, migration, or problem>
/dev-skills:plan <what should be planned>
```

When it helps (for example after research, before planning), also run:

```text
/dev-skills:architecture <what architecture should be analyzed or designed>
/dev-skills:data-model <what data model should be analyzed or designed>
```

Review the plan in `docs/01-plan.md`, then implement it phase by phase:

```text
/dev-skills:implement <optional: a specific phase>
```

`implement` implements one phase, runs its checks, ticks its boxes, and pauses
for your manual verification. Tell it to continue when you are ready for the
next phase.

## Opening a pull request

```text
/dev-skills:pr <optional: base branch, issue to link, "draft", or what to emphasize>
```

`pr` reads the whole branch against its base, commits what belongs to the
change, pushes the branch, and opens the pull request. If the branch already has
one, it rewrites the description so that it covers the new commits too.

The description always answers three questions:

```md
## Motivation
## What was done
## How to verify
```

A pull request is a record of the work, so `pr` writes nothing about the tools
behind it: no `Co-Authored-By` trailer for an AI model, no "Generated with …"
line, no mention of an agent in the commit messages, the title, or the body.

It also keeps to a few limits. It never pushes to the default branch, never
force-pushes unless you ask, stages files by name, and stops at the open pull
request without merging it. If the repository has its own pull request template,
`pr` fills that template and makes sure the three questions are still answered.

## Generated docs

The skills write these files into the project you run them in:

```text
docs/00-research.md
docs/01-plan.md
docs/02-architecture.md
docs/03-data-model.md
```

`architecture` and `data-model` are optional. The main line only requires:

```text
docs/00-research.md
docs/01-plan.md
```

> The numbers (`00`–`03`) indicate **document type**, not execution order. You can
> run `architecture` or `data-model` after research and before planning even
> though their files are numbered after `01-plan.md`.

## Optional: hard enforcement gate

If you want Claude to be *physically* unable to edit code before you approve
(rather than relying on the skills' instructions), install the second plugin:

```text
/plugin install phase-gate@vnovakovskyi-dev-skills
```

`phase-gate` adds one `PreToolUse` [hook](https://code.claude.com/docs/en/hooks)
(matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`) that runs
`scripts/gate.sh` before every file edit and shell command. The hook comes with
the plugin, so there is nothing to add to `settings.json` by hand, and
uninstalling the plugin removes it.

The hook needs `bash` and `jq`. If `jq` is missing, the hook fails open: it
allows everything and enforces nothing. On macOS: `brew install jq`.

The gate is **opt-in per project** via a marker file. In a project's root:

```bash
touch .claude-phase-gate          # enable the gate for this project
```

In a project without the marker, the hook does nothing.

While the gate is active and implementation is **not** approved, Claude may edit
docs/planning files but source-code edits are blocked. To approve:

```bash
touch .claude-phase-approved      # approve implementation (run this yourself)
```

Approval requires `docs/00-research.md` and `docs/01-plan.md` to exist plus the
`.claude-phase-approved` file. Do **not** let Claude create `.claude-phase-approved`
itself — that would defeat the gate (the gate blocks Claude from creating it).

### Gate behavior

Allowed before approval: `docs/**`, `CLAUDE.md`, `.claude/**`, `README.*`.

Blocked before approval: source/config/build/migration file edits, and
file-mutating shell commands. The Bash check is a **soft backstop** (not a full
shell parser):

- Blocks: `rm rmdir mv cp touch mkdir chmod chown ln dd tee truncate`, `sed -i`,
  `perl -pi`, and output redirection into a file (`> file`, `>> file`, etc.).
- Allows: read-only redirections (`2>&1`, `2>/dev/null`) and interpreters/build
  tools (`python`, `node`, `npm`, `make`, …), so research isn't obstructed.

If it ever blocks something harmless, approve implementation or temporarily
`rm .claude-phase-gate`.

### Caveat: approval is a persistent flag

`.claude-phase-approved` stays until you remove it, so if you re-run
`/dev-skills:plan` after approving, the *old* approval is still in effect. With
the gate, remove the file (`rm .claude-phase-approved`) when you re-plan. The
soft (default) workflow avoids this entirely because it has no approval file.

### Version control of the gate's marker files

The marker files live in each working project, so committing them is a
per-project decision (made in that project's `.gitignore`):

- **`.claude-phase-approved` — recommended to gitignore.** It is transient, local,
  per-developer state. If committed, every clone is permanently "approved".
- **`.claude-phase-gate` — your choice:** commit it to share the gate with the
  team, or gitignore it to keep the gate personal. For anyone without the plugin
  installed, the marker is an inert empty file and changes nothing.

Suggested per-project `.gitignore`:

```gitignore
# Local implementation approval — never commit (would disable the gate on clone)
.claude-phase-approved

# Phase-gate opt-in: uncomment to keep it personal/local instead of shared.
# .claude-phase-gate
```

## Versions and updates

Both plugins share one version number. It follows [semantic
versioning](https://semver.org), and every release has an entry in
[CHANGELOG.md](CHANGELOG.md):

- **Major:** a change that breaks a habit — a skill renamed or removed, a
  different output file or format.
- **Minor:** a new skill or a new capability.
- **Patch:** wording, examples, fixes.

You stay on the version you installed until you update. To see which one you
have:

```bash
claude plugin list
```

To update, refresh the marketplace and then the plugin:

```bash
claude plugin marketplace update vnovakovskyi-dev-skills
claude plugin update dev-skills@vnovakovskyi-dev-skills
```

A session that is already open keeps the version it loaded; run
`/reload-plugins` in it or start a new one. The same is available in the
`/plugin` panel, where the **Marketplaces** tab can also turn on auto-update for
this marketplace (it is off by default for marketplaces outside Anthropic's own).

Compare the version from `claude plugin list` with the top of
[CHANGELOG.md](CHANGELOG.md) to see how many releases you are behind and what
changed in each.

## Uninstall

Remove one plugin:

```text
/plugin uninstall phase-gate@vnovakovskyi-dev-skills
```

Or remove the marketplace, which also uninstalls every plugin installed from it:

```text
/plugin marketplace remove vnovakovskyi-dev-skills
```

Files the skills wrote into your projects (`docs/`, the gate's marker files) are
left untouched.

## Repository layout

```text
.claude-plugin/marketplace.json     the marketplace: lists the two plugins
plugins/dev-skills/                 the plugin with the six skills
  .claude-plugin/plugin.json
  skills/<name>/SKILL.md
plugins/phase-gate/                 the plugin with the optional hard gate
  .claude-plugin/plugin.json
  hooks/hooks.json
  scripts/gate.sh
CHANGELOG.md                        what changed in each version
```

## Contributing

Anyone is welcome to propose a change, and every change comes in through a pull
request: fork, make a small focused change on a branch, test it locally, and open
a PR against `main` for review. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
scope, the review flow, and how to test.

## License

Licensed under the [MIT License](LICENSE): free to use, copy, modify, and
distribute for any purpose, including commercial use. © 2026 Vadym Novakovskyi.
