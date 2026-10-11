# Claude Dev Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[Claude Code](https://code.claude.com) skills for a development workflow in
which Claude researches and plans before it writes code.

```text
research → plan → implement
```

Each step is a slash command that writes a document into your project's `docs/`
folder. You read it, correct it, and decide when to move on. Two optional
skills, `architecture` and `data-model`, cover design questions that deserve a
document of their own. A sixth skill, `pr`, turns the finished work into a pull
request.

Skills for reviewing articles and drafts live in a separate repository:
[claude-writer-skills](https://github.com/vnovakovskyi/claude-writer-skills).

## Skills

| Skill | What it does | Writes |
|---|---|---|
| `/research` | Investigates an idea, feature, problem, or existing codebase. Separates facts from assumptions, lists risks and open questions, and recommends the next step. | `docs/00-research.md` |
| `/plan` | Turns the research into a scoped plan split into small phases, each with automated and manual success criteria and an explicit "Out of Scope". | `docs/01-plan.md` |
| `/implement` | Implements one phase of the plan, runs its automated checks, ticks its checkboxes, then pauses for your manual verification. | code, and the checkboxes in `docs/01-plan.md` |
| `/architecture` | Optional. Documents, reviews, or proposes the architecture of a new idea or an existing service, with ADR-style decisions. | `docs/02-architecture.md` |
| `/data-model` | Optional. Documents, reviews, or redesigns the domain and data model: schemas, constraints, indexes, migrations, data flows. | `docs/03-data-model.md` |
| `/pr` | Commits what belongs to the change, pushes the branch, and opens or updates a pull request described in three parts: motivation, what was done, how to verify. | commits, and the pull request |

The five workflow skills run only when you type the command. Claude never starts
them on its own (`disable-model-invocation: true`). `/pr` also starts when you
ask for a pull request in plain words.

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
  then run `/implement`.
- `implement` does **one phase at a time**. It implements the phase, runs that
  phase's automated checks, ticks the `- [x]` boxes in the plan, and then
  **pauses and waits for you** to confirm manual verification before the next
  phase.

So approval is a normal conversational act (you choose to run `/implement`, and
you confirm between phases) — there is no approval file to create, forget, or
delete. Progress is tracked by the checkboxes inside `docs/01-plan.md`, so work
is resumable: re-running `/implement` picks up at the first unchecked phase.

> If you also want **hard** enforcement — where Claude is *physically* blocked
> from editing code until you approve — there is an optional hook. See
> [Optional: hard enforcement gate](#optional-hard-enforcement-gate).

## Requirements

- [Claude Code](https://code.claude.com).
- `bash`, to run the installer.

The optional hard gate (`--with-gate`) additionally needs:

- `python3` — to safely edit `~/.claude/settings.json`.
- `jq` — the hook uses it to parse its input. If `jq` is missing the hook fails
  open (allows everything, no enforcement). On macOS: `brew install jq`.

## Install

```bash
git clone https://github.com/vnovakovskyi/claude-dev-skills.git
cd claude-dev-skills
./install.sh
```

This symlinks every skill into `~/.claude/skills/`. It does **not** touch
`~/.claude/settings.json` and installs no hook.

If `~/.claude/skills/` already holds a real directory (not a symlink) with the
same name as one of the skills, the installer stops instead of overwriting it.
Move that directory, or run `FORCE=1 ./install.sh` to replace it.

> **Note:** the skills are installed as *symlinks back into this repository*. If
> you move, rename, or delete the clone, the skills stop working. Keep it in a
> stable location, and re-run `./install.sh` if you move it. The upside: a
> `git pull` updates the installed skills at once (re-run `./install.sh` to pick
> up skills added since).

## Usage

Run Claude Code inside your project and start with the main line:

```text
/research <idea, feature, migration, or problem>
/plan <what should be planned>
```

When it helps (for example after research, before planning), also run:

```text
/architecture <what architecture should be analyzed or designed>
/data-model <what data model should be analyzed or designed>
```

Review the plan in `docs/01-plan.md`, then implement it phase by phase:

```text
/implement <optional: a specific phase>
```

`/implement` implements one phase, runs its checks, ticks its boxes, and pauses
for your manual verification. Tell it to continue when you are ready for the
next phase.

## Opening a pull request

```text
/pr <optional: base branch, issue to link, "draft", or what to emphasize>
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
(rather than relying on the skills' instructions), install the optional hook:

```bash
./install.sh --with-gate
```

This symlinks `hooks/gate.sh` into `~/.claude/hooks/` and adds a `PreToolUse`
[hook](https://code.claude.com/docs/en/hooks) (matcher
`Write|Edit|MultiEdit|NotebookEdit|Bash`) to `~/.claude/settings.json`. Existing
settings are preserved: the installer backs up `settings.json` to
`settings.json.bak`, then appends the hook only if it isn't already registered,
so it is safe to run multiple times. To register the hook by hand instead, merge
[settings-snippet.json](settings-snippet.json) into your settings.

The gate is **opt-in per project** via a marker file. In a project's root:

```bash
touch .claude-phase-gate          # enable the gate for this project
```

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

`.claude-phase-approved` stays until you remove it, so if you re-run `/plan`
after approving, the *old* approval is still in effect. With the gate, remove the
file (`rm .claude-phase-approved`) when you re-plan. The soft (default) workflow
avoids this entirely because it has no approval file.

### Version control of the gate's marker files

The marker files live in each working project, so committing them is a
per-project decision (made in that project's `.gitignore`):

- **`.claude-phase-approved` — recommended to gitignore.** It is transient, local,
  per-developer state. If committed, every clone is permanently "approved".
- **`.claude-phase-gate` — your choice:** commit it to share the gate with the
  team, or gitignore it to keep the gate personal. For anyone without the hook
  installed, the marker is an inert empty file and changes nothing.

Suggested per-project `.gitignore`:

```gitignore
# Local implementation approval — never commit (would disable the gate on clone)
.claude-phase-approved

# Phase-gate opt-in: uncomment to keep it personal/local instead of shared.
# .claude-phase-gate
```

## Uninstall

Run the uninstaller from this repository:

```bash
./uninstall.sh
```

It removes the skill symlinks (only those that point back into this repo) and,
if the optional gate was installed, removes the `gate.sh` symlink and its
`PreToolUse` entry from `~/.claude/settings.json` (backing the file up to
`settings.json.bak` first), leaving all your other settings intact. Per-project
marker files are left untouched.

## Note about `/plan` and `/pr`

`plan` and `pr` are short and convenient names, but they are also generic.

If one conflicts with an existing Claude Code command or your own setup, rename
the skill folder and frontmatter `name` to something more specific, for example:

```text
mvp-plan
product-plan
phase-plan
open-pr
```

## Repository layout

```text
skills/<name>/SKILL.md   one skill per folder
hooks/gate.sh            the optional hard gate (PreToolUse hook)
settings-snippet.json    the hook entry, for registering it by hand
install.sh               symlinks the skills (and, with --with-gate, the hook)
uninstall.sh             reverses what install.sh did
```

## Contributing

Anyone is welcome to propose a change, and every change comes in through a pull
request: fork, make a small focused change on a branch, test it locally, and open
a PR against `main` for review. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
scope, the review flow, and how to test.

## License

Licensed under the [MIT License](LICENSE): free to use, copy, modify, and
distribute for any purpose, including commercial use. © 2026 Vadym Novakovskyi.
