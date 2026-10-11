# The workflow

```text
research → plan → implement → pr
```

## How the workflow keeps Claude from coding too early

The workflow uses a **soft, conversational gate** — no hook, no marker files in
the normal flow. The discipline lives in the skills themselves:

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
> [phase-gate.md](phase-gate.md).

## The main line

Run Claude Code inside your project and start with:

```text
/dev-skills:research <idea, feature, migration, or problem>
/dev-skills:plan <what should be planned>
```

Review the plan in `docs/01-plan.md`, then implement it phase by phase:

```text
/dev-skills:implement <optional: a specific phase>
```

`implement` implements one phase, runs its checks, ticks its boxes, and pauses
for your manual verification. Tell it to continue when you are ready for the
next phase.

## The optional skills

```text
/dev-skills:architecture <what architecture should be analyzed or designed>
/dev-skills:data-model <what data model should be analyzed or designed>
```

Use them whenever they help:

- After research, before planning.
- Inside an existing service, to document or review its current architecture.
- Inside an existing service, to review or redesign its data model.
- Before a migration or a refactoring.

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

## Opening a pull request

```text
/dev-skills:pr <optional: base branch, then "draft", an issue to link, or what to emphasize>
```

`pr` reads the whole branch against its base, commits what belongs to the
change, pushes the branch, and opens the pull request. If the branch already has
one, it rewrites the description so that it covers the new commits too.

The base is the branch the pull request goes into. Without arguments it is the
repository's default branch. Name a branch first to target that one instead:

```text
/dev-skills:pr dev
/dev-skills:pr dev draft
```

If the branch you name does not exist on the remote yet, `pr` creates it from
the default branch and tells you so.

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

## Who starts a skill

The five workflow skills run only when you type the command. Claude never starts
them on its own (`disable-model-invocation: true`). `pr` also starts when you ask
for a pull request in plain words.

Every command carries the plugin's name. Short names such as `plan` or
`research` are easy to collide with, both with built-in commands and with other
skills you have installed. The `dev-skills:` prefix rules that out.
