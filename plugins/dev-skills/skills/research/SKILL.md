---
name: research
description: Main workflow phase 1. Research an idea, feature, problem, or technical change before planning or coding. Starts from what the knowledge base already knows, and writes the research into a case under docs/cases/ of the folder Claude was started in. No implementation.
argument-hint: <idea, feature, problem, or change to research>
disable-model-invocation: true
---

# Phase: Research

You are running the **Research** phase for the user's request.

User request / topic:

`$ARGUMENTS`

## Purpose

Understand the problem deeply before any product planning, architecture design, data modeling, or implementation.

This phase may be used for:

- A new product idea.
- A new feature.
- A technical migration.
- A bug-prone or legacy area that needs analysis before action.

This phase is about the task: understanding it, finding the information it
needs, and weighing it. It is not for explaining how existing code works. When
the request is only a question about the code, tell the user that
`/dev-skills:research-codebase` answers it, and stop.

## Hard rules

- Do **not** write implementation code.
- Do **not** create database migrations.
- Do **not** change production files.
- Do **not** jump into architecture unless the architecture is only being observed as part of research.
- Do **not** create the MVP plan yet.
- You may inspect the repository.
- You may create or update files only in the knowledge base: `docs/` of the
  folder Claude was started in, never inside a repository's tracked files.
- Main output is `research.md` in the case folder, plus the case's `case.md`.

## The knowledge base

Read `../../references/knowledge-base.md` (from this skill's base directory)
before anything else. It defines where the knowledge base lives, what a case
is, the `case.md` card, how to search it, and how to rebuild the index.

## Working process

1. Clarify the target of research from `$ARGUMENTS`.
2. **Search the knowledge base first**, as the reference describes: the index,
   then the cards and codebase notes that match the request's error texts,
   services, repositories, tickets, and libraries. What was already found or
   fixed elsewhere is the starting point, not a footnote.
3. **Pick the case.** Continue the matching case when the subject is the same
   (the same error in another service counts); otherwise create a new one.
   Write its slug to `docs/.active`. Tell the user which case you continue or
   created, and why.
4. Gather the information the task needs: the request, the project's docs, and
   outside sources such as documentation, standards, and comparable solutions
   when your environment can reach them. Look at the code only as far as the
   task needs it (the affected modules, integration points, constraints). If
   the task depends on code nobody has investigated yet, recommend
   `/dev-skills:research-codebase` for it.
5. Identify the problem, context, constraints, assumptions, and risks.
6. Separate facts from assumptions.
7. Identify unknowns and open questions.
8. Recommend whether the work should move to planning.
9. Write `research.md` (a later round in an existing case:
   `research-<YYYY-MM-DD>-<subject>.md`, the subject in a few kebab-case
   words), create or update `case.md` — `Problem`, `Findings`, `symptoms`,
   `services`, `repos`, `tickets`, `summary`, status `open` — and run
   `reindex.sh`.

## Output file

Create or update `docs/cases/<case>/research.md`, and the case's `case.md`
(see the reference).

Use this structure for `research.md`:

```md
# Research

## 0. Prior work

Cases and codebase notes from the knowledge base that bear on this request,
each with its path and what it tells us. "None found" when there is nothing.

## 1. Request

Short summary of what was asked.

## 2. Context

What is known from the user request, repository, documentation, and existing files.

## 3. Problem / Opportunity

What problem we are solving or what opportunity we are exploring.

## 4. Target Users / Stakeholders

Who benefits from this work.

For technical/internal work, include engineering stakeholders, product stakeholders, operations, security, support, or users affected by the change.

## 5. Current State

For existing projects:
- Current implementation.
- Relevant modules/files.
- Current limitations.
- Existing dependencies.

For new projects:
- Current idea maturity.
- Existing alternatives.
- Known constraints.

## 6. Findings

Concrete findings from research.

Use bullets with evidence where possible:
- Finding
- Why it matters
- Source/file/reference, if applicable

## 7. Assumptions

Explicit assumptions that need validation.

## 8. Risks

Technical, product, delivery, security, operational, cost, data, and maintainability risks.

## 9. Open Questions

Questions that should be answered before or during planning.

## 10. Recommendation

Recommended next step:
- Continue to `plan`
- Run `research-codebase` first, to understand the code the task touches
- Run `architecture` first
- Run `data-model` first
- Stop / rethink

## 11. Next Action

Specific next command or action the user should run.
```

## Completion criteria

Research is complete only when:

- The knowledge base was searched, and "Prior work" says what it found.
- `research.md` and `case.md` exist in the case folder, `docs/.active` names
  the case, and the index was rebuilt.
- Facts and assumptions are clearly separated.
- Risks and unknowns are listed.
- A clear recommendation is given for the next phase.

At the end of your response, summarize:

1. What you found.
2. Which case you created or continued, and the prior work you found.
3. What the next recommended phase is.
