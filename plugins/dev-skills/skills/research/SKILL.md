---
name: research
description: Main workflow phase 1. Research an idea, feature, problem, or technical change before planning or coding. Produces docs/00-research.md. No implementation.
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
- You may create or update files under `docs/`.
- Main output must be `docs/00-research.md`.

## Working process

1. Clarify the target of research from `$ARGUMENTS`.
2. Gather the information the task needs: the request, the project's docs, and
   outside sources such as documentation, standards, and comparable solutions
   when your environment can reach them.
3. In an existing project, read `docs/codebase/` first if it exists: it holds
   earlier code investigations. Look at the code only as far as the task needs
   it (the affected modules, integration points, constraints). If the task
   depends on code nobody has investigated yet, recommend
   `/dev-skills:research-codebase` for it.
4. Identify the problem, context, constraints, assumptions, and risks.
5. Separate facts from assumptions.
6. Identify unknowns and open questions.
7. Recommend whether the work should move to planning.

## Output file

Create or update:

`docs/00-research.md`

Use this structure:

```md
# Research

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

- `docs/00-research.md` exists.
- Facts and assumptions are clearly separated.
- Risks and unknowns are listed.
- A clear recommendation is given for the next phase.

At the end of your response, summarize:

1. What you found.
2. What document you created/updated.
3. What the next recommended phase is.
