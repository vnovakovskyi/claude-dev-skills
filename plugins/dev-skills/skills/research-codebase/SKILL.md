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
  out code smells, or propose a design unless the user asks for it. Places where
  the code contradicts itself are facts, and they go in their own section of the
  answer (see below), stated without a recommendation.
- **Every claim has a source.** Name the file and line (`path/to/file.ext:42`)
  for each statement about the code. If you could not find something, say so
  instead of guessing.
- **Keep what you saw apart from what you infer.** When a step is an inference
  (a call through an interface, a value from configuration you could not read,
  reflection, a generated file), mark it as such.
- **Write a file only when asked.** By default the answer goes into the chat.
  Write `docs/codebase/<topic>.md` only when the user asks to save it, in the
  arguments or later in the conversation.
- **The rules bind subagents too.** A subagent does not see this skill. Every
  brief you give one carries these rules.

## Working process

1. **Pin down the question.** Restate it in one line. If it can be read in very
   different ways, ask one short question; otherwise take the most likely reading
   and say which one you took.
2. **Find the scope.** When the working directory is one repository, that is the
   scope. When it holds several repositories, or the question crosses into
   services, infrastructure, or libraries that live in other repositories, decide
   which repositories matter and name them in one line in the answer. Do not
   search the others.
3. **Start from what is written.** In each repository in scope, look at
   `docs/codebase/` first, then the README and the project's own docs. When a
   `docs/codebase/` file covers the question, check what changed since the commit
   it records (`git log --oneline <hash>..HEAD -- <paths it cites>`), keep what
   still holds, and re-check the rest.
4. **Read what the user named first.** Files, classes, endpoints, or tickets the
   user mentioned are read in full before you search anywhere else.
5. **Find the starting points.** Search for names, domain terms, routes, message
   or event names, configuration keys, and error texts. Look at entry points
   (handlers, controllers, jobs, consumers, CLI commands), at tests, which show
   how the code is meant to be used, and at the project's own docs.
6. **Size the work.**
   - A narrow question (where X is, one flow inside one service): answer it
     yourself, without subagents.
   - A broad question (several services, layers, or repositories): split it into
     2–4 sub-questions whose areas do not overlap, cut by layer, service, or
     repository. Tell the user in one line how you split it.
   - If your environment offers subagents, run the sub-questions in parallel with
     the brief in `references/subagent-brief.md` (in this skill's directory).
     Locating code is a good job for a read-only search agent and a cheaper model.
   - While subagents run, do not search their areas yourself. Work on what no
     subagent owns, or wait.
7. **Trace the flow.** Follow the path from the entry point through the layers to
   the data and to the side effects: database writes, calls to other services,
   messages, files. Note the configuration and feature flags that change the
   path, and where the code crosses into another service or library.
8. **Answer "why" from history.** When the question is why the code is the way it
   is, look at `git log`, `git blame`, and the commits and pull requests that
   introduced the lines. Quote what they say; do not invent a motive.
9. **Check before you answer.** Reopen each line you cite and make sure it says
   what your answer says. This includes every claim a subagent reported: its
   paths and line numbers can be wrong. Batch the checks, one read per file. A
   claim that does not hold is dropped or moved to "Not confirmed".

## Answer in the chat

Write in the language the user asked in, the headings included. Use this shape,
and drop a section that would be empty:

```md
**Question:** <the question in one line, as you understood it>

**Scope:** <the repositories you searched — only when there is more than one>

**Short answer:** 2–5 sentences that answer it directly.

**How it works**
1. Step — what happens, `path/to/file.ext:42`
2. Step — …

**Key places**
- `path/to/file.ext:10` — what is there

**Inconsistencies in the code**
- Where the code contradicts itself: both sides, each with its source.

**Not confirmed**
- What you could not verify, and why.
```

- **Sources.** Write each source in the form your environment can open: a
  markdown link (`[file.ext:42](path/to/file.ext:42)`) where links are clickable,
  `path/to/file.ext:42` in a plain terminal. For a file in another repository,
  name the repository and give the path from its root.
- **Diagram.** When the flow crosses several services, a short diagram after the
  short answer helps: a one-line chain (`Host → proxy → header → service → DB`)
  or a Mermaid sequence diagram.
- **Narrow questions.** For a "where is X" question, the short answer and the key
  places are enough.

After the answer, add one line saying that the user can ask you to save it.

## Saving to docs/codebase/

When the user asks to save, write `docs/codebase/<topic>.md`, where `<topic>` is
a short kebab-case name for the subject (`payment-retries`, `auth-flow`). If a
file on the same subject exists, update it instead of creating another one.
When the scope spans several repositories, save it in the repository that owns
most of the subject.

```md
# <Topic>

**Question:** <the question>
**Researched:** <date>, at commit `<short hash from git rev-parse --short HEAD>`

## Short answer

## How it works

## Key places

## Inconsistencies in the code

## Not confirmed
```

With several repositories in scope, record one commit per repository:

```md
**Researched:** <date>; <repo> `<short hash>`, <repo> `<short hash>`
```

The commits tell a later reader how old the description is. Other skills read this folder:
`/dev-skills:research` uses it as context for a task.

## Completion criteria

The skill is complete only when:

- The question is answered, or you said clearly what you could not find.
- Every statement about the code points to a file and line, and you reopened
  each cited line yourself, the ones subagents reported included.
- The repositories searched are named when there is more than one.
- Nothing outside `docs/codebase/` was changed, and that folder only on request.
