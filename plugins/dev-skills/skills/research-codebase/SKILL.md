---
name: research-codebase
description: Investigate the existing code to answer a question about it — where something lives, how a flow works, why the code behaves the way it does. Answers in the chat with file:line evidence; writes docs/codebase/<topic>.md only when asked. Read-only, no implementation.
argument-hint: '<question about the code, or an area to explain; add "save" to write it to docs/codebase/>'
disable-model-invocation: true
---

# Research the codebase

You are running the **Research the codebase** skill.

User question:

`$ARGUMENTS`

## Purpose

Answer a question about the code as it is: where something is, how it works,
what calls what, where data comes from and where it goes, why it behaves the way
it does. The user reads the answer and comes away understanding that part of the
code, with the places to look at.

This is not `/dev-skills:research`. That skill thinks about a task before it is
planned. This one explains the existing code and stops there.

## Hard rules

- **Read-only.** Do not change code, configuration, dependencies, or data. Do not
  run commands that write anything: installs, migrations, code generators,
  formatters. Reading, searching, `git log`, `git blame`, and `git show` are fine.
- **Describe what is, not what should be.** Do not suggest improvements, point
  out code smells, or propose a design unless the user asks for it.
- **Every claim has a source.** Name the file and line (`path/to/file.ext:42`)
  for each statement about the code. If you could not find something, say so
  instead of guessing.
- **Keep what you saw apart from what you infer.** When a step is an inference
  (a call through an interface, a value from configuration you could not read,
  reflection, a generated file), mark it as such.
- **Write a file only when asked.** By default the answer goes into the chat.
  Write `docs/codebase/<topic>.md` only when the user asks to save it, in the
  arguments or later in the conversation.

## Working process

1. **Pin down the question.** Restate it in one line. If it can be read in very
   different ways, ask one short question; otherwise take the most likely reading
   and say which one you took.
2. **Read what the user named first.** Files, classes, endpoints, or tickets the
   user mentioned are read in full before you search anywhere else.
3. **Find the starting points.** Search for names, domain terms, routes, message
   or event names, configuration keys, and error texts. Look at entry points
   (handlers, controllers, jobs, consumers, CLI commands), at tests, which show
   how the code is meant to be used, and at the project's own docs.
4. **Split a broad question.** When the question spans several independent areas,
   split it into sub-questions. If your environment offers subagents, run the
   sub-questions in parallel and ask each one for file:line evidence. Then open
   the key places yourself before you rely on them.
5. **Trace the flow.** Follow the path from the entry point through the layers to
   the data and to the side effects: database writes, calls to other services,
   messages, files. Note the configuration and feature flags that change the
   path, and where the code crosses into another service or library.
6. **Answer "why" from history.** When the question is why the code is the way it
   is, look at `git log`, `git blame`, and the commits and pull requests that
   introduced the lines. Quote what they say; do not invent a motive.
7. **Check before you answer.** Reopen each line you cite and make sure it says
   what your answer says.

## Answer in the chat

Use this shape, and drop a section that would be empty:

```md
**Question:** <the question in one line, as you understood it>

**Short answer:** 2–5 sentences that answer it directly.

**How it works**
1. Step — what happens, `path/to/file.ext:42`
2. Step — …

**Key places**
- `path/to/file.ext:10` — what is there

**Not confirmed**
- What you could not verify, and why.
```

For a "where is X" question, the short answer and the key places are enough.
After the answer, add one line saying that the user can ask you to save it.

## Saving to docs/codebase/

When the user asks to save, write `docs/codebase/<topic>.md`, where `<topic>` is
a short kebab-case name for the subject (`payment-retries`, `auth-flow`). If a
file on the same subject exists, update it instead of creating another one.

```md
# <Topic>

**Question:** <the question>
**Researched:** <date>, at commit `<short hash from git rev-parse --short HEAD>`

## Short answer

## How it works

## Key places

## Not confirmed
```

The commit tells a later reader how old the description is. Other skills read
this folder: `/dev-skills:research` uses it as context for a task.

## Completion criteria

The skill is complete only when:

- The question is answered, or you said clearly what you could not find.
- Every statement about the code points to a file and line.
- Nothing outside `docs/codebase/` was changed, and that folder only on request.
