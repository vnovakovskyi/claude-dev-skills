---
name: plan
description: Main workflow phase 2. Turn research into a scoped plan split into small, verifiable phases, for a feature, a fix, an upgrade, or a migration. Writes plan.md into a case of the knowledge base. No implementation.
argument-hint: <what should be planned>
disable-model-invocation: true
---

# Phase: Plan

You are running the **Plan** phase for the user's request.

User request / topic:

`$ARGUMENTS`

## Purpose

Convert research into a clear, scoped, executable plan before coding starts.

This is the main line after `research`. The research can also come from
`research-codebase` notes and from the current conversation (see "Required
inputs").

Optional supporting phases may exist:

- `architecture` — if architecture decisions are needed.
- `data-model` — if domain model, persistence, schema, or data flow decisions are important.

If the case holds `architecture.md` or `data-model.md`, read and incorporate them. Do not require them unless the research shows they are necessary.

## The knowledge base

Read `../../references/knowledge-base.md` (from this skill's base directory)
first, and search the knowledge base as it describes. Then pick the case:

1. the case named in `$ARGUMENTS`;
2. else the one in `docs/.active`, when it is about the same subject;
3. else a case the index shows for the same subject (reuse before you create);
4. else create one as the reference describes.

Write its slug to `docs/.active` and tell the user which case you continue or
created, and why. Below, "the case" means `docs/cases/<that slug>/`.

## Hard rules

- Do **not** write implementation code.
- Do **not** create database migrations.
- Do **not** modify production files.
- Do **not** expand the scope beyond what research supports.
- You may create or update files only in the knowledge base, never inside a
  repository's tracked files.
- Main output is `plan.md` in the case folder.
- **Write files in the knowledge base's language** (see the reference), the
  headings included; talk to the user in theirs.
- **Keep the phase structure `implement` reads.** Every phase keeps the parts
  of the template, in its order. Word each label one way and use that wording
  in every phase: `implement` recognizes the parts by what they say, not by
  their labels, and one wording per part leaves nothing to guess.
- **Every fact has a source**: a file and line, a command, or a URL. Mark a
  fact you could not verify as such.
- **The rules bind subagents too.** A subagent does not see this skill. Every
  brief you give one carries these rules.

## Required inputs

Before planning, read:

- the case's `case.md` and its latest `research*.md`;
- `docs/codebase/` notes on the same subject;
- the case's `architecture.md` and `data-model.md`, when present;
- other cases the card lists under `related`, and any case the index shows for
  the same services: a plan that already failed or succeeded there is input.

The research may live in different places:

- **In the case** (`research*.md`): use it.
- **Only in `docs/codebase/` notes or in this conversation** (for example,
  after `/dev-skills:research-codebase`): write it into the case as
  `research.md` (or `research-<YYYY-MM-DD>-<subject>.md` when the case already
  has one). Say at the top which notes and which conversation it comes from,
  and keep only what the plan needs. Tell the user you did this.
- **Nowhere**: ask the user to run `/dev-skills:research` (or
  `/dev-skills:research-codebase` for a question about how the code works)
  first. Write a rough plan with a short research section inside it only when
  the user explicitly asks for a fast plan.

## Planning principles

The plan must be:

- Small enough to implement.
- Clear enough to test.
- Explicit about what is **in scope** and **out of scope**.
- Split into small, independently verifiable implementation phases.
- Honest about risks and unknowns.
- Useful for a real developer, not just a high-level product note.
- **Short enough to read.** The sections before the phases fit on about two
  screens. Leave out a section, or a sentence, that only repeats another one.

**Look it up before you ask.** Before you write an open question, check whether
a search can answer it: a version in a config file, a setting in the
infrastructure code, an existing ticket, a library's release notes. Only what
needs a person or a decision goes to "Open Questions".

**Know where you can write.** For every repository the plan changes, check the
user's access (`gh repo view <owner>/<repo> --json viewerPermission`). Read
access only means the phase needs a fork, or someone to grant access or to
merge: put that in the phase's outward actions and, when it needs a person, in
"Open Questions". For a repository many others build from (shared CI, a shared
library), also say who uses it and who reviews changes to it.

**Write outward actions as commands.** An outward action that runs a workflow,
a deploy, or a release names the exact command with its inputs, checked against
how the workflow reads them (its `inputs` and the step that parses them), so
that `implement` does not learn the format from a failed run.

## Working process

1. Pick the case and read the inputs (see above). Note the prior work you found.
2. Fill the gaps the plan needs and research left open, by looking them up
   (see "Look it up before you ask").
3. Write the plan in the structure below.
4. **Check the plan before you hand it over.**
   - Reopen every file and line the plan cites and make sure it says what the
     plan says.
   - Run the cheap, read-only commands the success criteria name (a lint, a
     listing, a dry run) once, to make sure they exist and work as written. Do
     not run commands that build, deploy, or write. Check flags too: a quiet
     flag that hides the error a check is meant to show makes the check
     useless.
   - Make sure no open question blocks Phase 1.
5. Write `case.md` (`Decision`, `updated`, status `open`) and rebuild the index.

## Output file

Create or update `plan.md` in the case folder. When a plan already exists
and the user asks for a new one rather than a revision, write
`plan-<YYYY-MM-DD>-<subject>.md` and keep the old one.

Use this structure. Sections 5 and 6 depend on the kind of work: use the
variant that fits, or leave the section out when it would add nothing.

**A short plan for small work.** When every phase is size S and the work needs
no architecture or data-model decision, write only the header, 0 (when prior
work exists), 1, 3, 9, 13, and 14, and fold the few risks that matter into the
phases. The phases keep every part of the template.

````md
# Plan: <subject>

**Date:** <YYYY-MM-DD>
**Repos:** <repo> `<base branch>` `<short commit>` <access: write / read only> (one per repository; `implement` starts each phase's branch from that base)
**Inputs:** <research files, codebase notes, related cases>

## 0. Prior work

Cases and codebase notes that bear on this plan, each with its path and what it
changes for the plan. "None found" when there is nothing.

## 1. Goal

What we are trying to achieve.

## 2. Background

Short summary based on research: only what the reader needs to follow the
phases.

## 3. Scope

### In Scope

What will be included.

### Out of Scope

What will not be included now.

## 4. Success Criteria

How we know the work is successful, as checkable statements: product,
technical, operational (performance, reliability, observability, security,
cost), and quality criteria where relevant.

## 5. Use Cases

- Feature: the user stories or main flows.
- Upgrade, migration, infrastructure, fix: the engineering scenarios that must
  keep working (deploy one service, roll back, keep shipping features during
  the change).

## 6. Requirements

- Feature: numbered functional requirements.
- Upgrade, migration, infrastructure: numbered rules every phase follows (which
  versions, which patterns are allowed, what must not be used).
- Upgrade of a framework, a server, or a library: the rules include that every
  phase lists the versions that move in its dependency tree (transitive ones
  too) and checks their behavior changes against the module, and that every
  group of endpoints has a test through the real server with what real clients
  send (authentication, custom headers, their case). A mocked server does not
  see a change in the server.

## 7. Dependencies and People

Internal and external dependencies. Who does the work and who reviews it, when
the research or the user names them.

## 8. Risks and Mitigations

Risk → impact → mitigation. An unknown that needs an answer goes to "Open
Questions", not here.

## 9. Implementation Phases

Break the work into small, independently verifiable **phases**. Implementation
will be done one phase at a time, pausing for the user after each.

### Common checks

Commands and manual checks that several phases share, written once. A phase
names the ones it uses (for example "Common checks A1–A3 for `<module>`").
Leave this out when no checks repeat.

### Phase N: <short descriptive name>

**Goal:** What this phase accomplishes.

**Depends on:** phase numbers, or "nothing". **Can run in parallel with:**
phase numbers, when true.

**Size:** S, M, or L, with one line on what drives it.

**Files/modules likely affected:** List the probable files.

**Changes:** Short description of the change.

**Outward actions:** actions others see (close or comment on a pull request,
release to production, send a message, change shared settings), each as the
exact command when it runs one. `implement` asks the user before each one.
"None" when there are none.

**Rollback:** how to undo the phase if it goes wrong.

**Success criteria — Automated:**
- [ ] <command for this repo's tooling> tests pass
- [ ] <command> static checks / type / lint pass
- [ ] <command> build/compile succeeds (if relevant)

**Success criteria — Manual, before merge:**
- [ ] <behaviour the user should verify by hand>
- [ ] No regressions in <related area>

**Success criteria — Manual, after merge:** (only when the merge itself
deploys somewhere to check, such as a test or staging environment, before the
next phase or the production release)
- [ ] <what to check there>

**Success criteria — Manual, after rollout:** (only when the phase is deployed
and needs time to prove itself, such as a day in production)
- [ ] <what to watch, and for how long>

A check that needs an open pull request (CI on it, a label or a preview
environment, a reviewer's approval) says so: `implement` runs it after the
pull request is opened.

> After the automated checks pass and the pull request is open, **pause** and
> let the user confirm manual verification before starting the next phase.

### Repeated phases

When several phases follow one recipe (one per service, one per module), write
the recipe once as a phase block without a number, and list the phases in a
table: one row per phase, with only what differs. Each row is still a phase with
its own number and checkboxes:

| Phase | Target | What differs | Depends on | Size | Automated | Manual, before merge | Manual, after merge | Manual, after rollout |
|---|---|---|---|---|---|---|---|---|
| N | <module> | <specifics> | <phases> | S | [ ] | [ ] | [ ] | [ ] |

## 10. Testing Strategy

Only what the phases' criteria do not already say: test levels, contract
snapshots, test data, observability checks.

## 11. Rollout / Migration Strategy

Only if relevant.

## 12. Documentation Updates

What documentation must be created or updated.

## 13. Open Questions

| # | Question | Who answers | Blocks |
|---|---|---|---|
| 1 | <question> | <person or role> | Phase N / nothing |

No question may block Phase 1. `implement` asks about a question that blocks
the phase it is about to start.

## 14. Next Step

The phase to implement first, and the command to start it.
````

## Completion criteria

Planning is complete only when:

- `plan.md` exists in the case folder, written in the knowledge base's language.
- Every repository in the header says whether the user can write to it.
- `case.md` has a `Decision` section that says what was chosen, its `updated`
  is today, and the index was rebuilt.
- Scope is explicit (including an explicit "Out of Scope").
- Work is broken into phases, each with automated and manual success criteria,
  dependencies, outward actions, and a rollback.
- The cited lines and the cheap commands in the criteria were checked.
- Every open question says which phase it blocks, and none blocks Phase 1.
- "Next Step" names the first phase.

## Do not implement

This phase produces a plan only. Do **not** write code. End by asking the user
to review the plan and, when satisfied, to run `/dev-skills:implement` for the
first phase. Implementation begins only when the user explicitly invokes it.

When the folder Claude was started in has a `.claude-phase-gate` file, the
`phase-gate` plugin blocks code edits until the user approves. Give them the
command to run themselves, and never run it or write the file for them:

```bash
echo <case slug> > docs/.approved
```

At the end of your response, say in a few lines:

1. Where the plan is and how many phases it has.
2. Whether architecture or data-model analysis is recommended before implementation.
3. The first phase, the open questions that block later phases, and the
   reminder that you will pause after each phase for their verification.
