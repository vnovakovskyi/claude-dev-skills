---
name: research-codebase
description: Investigate the existing code to answer a question about it — where something lives, how a flow works, why the code behaves the way it does, and, when asked, how big a change to it would be. Answers in the chat with file:line evidence; when asked, saves the answer to docs/codebase/<topic>.md in the folder Claude was started in, never inside a repository's tracked files. Read-only, no implementation.
argument-hint: '<question about the code, or an area to explain; add "save" to keep the answer in docs/codebase/ of the folder you started Claude in>'
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
  formatters, and build tools that refresh a cache as a side effect (`nx graph`,
  `mvn`, `gradle`). Read a cache that is already there instead. Reading,
  searching, `git log`, `git blame`, `git show`, `git diff`, and read-only
  `gh` calls are fine.
- **Describe what is, not what should be.** Do not suggest improvements, point
  out code smells, or propose a design unless the user asks for it. Places where
  the code contradicts itself are facts, and they go in their own section of the
  answer (see below), stated without a recommendation.
- **Judgement only on request, and kept apart.** When the user asks how big,
  how hard, how risky, or in what order — an estimate or a recommendation —
  give it, in its own section, built on the facts above it and labelled as your
  judgement. Never mix it into "How it works".
- **Every claim has a source.** Name the file and line (`path/to/file.ext:42`)
  for each statement about the code. A fact from outside the code (a library's
  release notes, a support calendar, a migration guide) gets a URL; without one,
  mark it as general knowledge that you did not verify for this version. If you
  could not find something, say so instead of guessing.
- **Keep what you saw apart from what you infer.** When a step is an inference
  (a call through an interface, a value from configuration you could not read,
  reflection, a generated file), mark it as such.
- **Write a file only when asked.** By default the answer goes into the chat.
  Save it (see "Saving the answer") only when the user asks, in the arguments or
  later in the conversation. Never create or change a file inside a repository's
  tracked tree, and never edit a `.gitignore`.
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
3. **Know which code you are reading.** In each repository in scope, note the
   branch and the short commit. When the branch is not the default one, compare
   the paths that matter with the default branch
   (`git diff --stat origin/<default>...HEAD -- <paths>`) and say which state
   the answer describes.
4. **Start from what is written.** Search the knowledge base first, as
   `../../references/knowledge-base.md` (from this skill's base directory)
   describes: its index, codebase notes, and the case cards that name the same
   services or errors. Then the README and the project's own docs. When a saved
   note covers the question, check what changed since the commits it records
   (`git log --oneline <hash>..HEAD -- <paths it cites>`), keep what still
   holds, and re-check the rest.
5. **Read what the user named first.** Files, classes, endpoints, or tickets the
   user mentioned are read in full before you search anywhere else.
6. **Find the starting points.** Search for names, domain terms, routes, message
   or event names, configuration keys, and error texts. Look at entry points
   (handlers, controllers, jobs, consumers, CLI commands), at tests, which show
   how the code is meant to be used, and at the project's own docs. For
   questions about building, releasing, or upgrading, the evidence is also in
   build files, Dockerfiles, CI workflows, the build tool's dependency graph,
   and the checks and runs of recent pull requests.
7. **Size the work.**
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
8. **Trace the flow.** Follow the path from the entry point through the layers to
   the data and to the side effects: database writes, calls to other services,
   messages, files. Note the configuration and feature flags that change the
   path, and where the code crosses into another service or library.
9. **Answer "why" from history.** When the question is why the code is the way it
   is, look at `git log`, `git blame`, and the commits and pull requests that
   introduced the lines. Quote what they say; do not invent a motive.
10. **Check before you answer.** Reopen every line the answer cites and make sure
    it says what the answer says, the lines subagents reported included: their
    paths and line numbers can be wrong. Re-run the command behind every count
    the answer states, or label the count as reported by a subagent. Batch the
    checks, one read per file. A claim that does not hold is dropped or moved to
    "Not confirmed".

## Answer in the chat

Write in the language the user asked in, the headings included. Use this shape,
and drop a section that would be empty:

```md
**Question:** <the question in one line, as you understood it>

**Scope:** <the repositories you searched, with branch and commit — only when there is more than one, or the branch is not the default>

**Short answer:** 2–5 sentences that answer it directly.

**How it works**
1. Step — what happens, `path/to/file.ext:42`
2. Step — …

**Key places**
- `path/to/file.ext:10` — what is there

**Assessment** <only when the user asked for an estimate, a risk, an order, or a recommendation>
- Your judgement, each point tied to the facts above.

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

## Saving the answer

Saved answers are personal notes. They live outside every repository's tracked
files, so they never show up in a diff, and nobody has to add them to a shared
`.gitignore`.

**Where.** Write `docs/codebase/<topic>.md` in the knowledge base: the `docs/`
folder of the folder Claude was started in, not the repository you researched.
`../../references/knowledge-base.md` says how to keep it out of a repository's
changes when that folder is itself a repository. After writing, rebuild the
index with `reindex.sh` as the reference describes.

**Name.** `<topic>` is a short kebab-case name for the subject
(`payment-retries`, `auth-flow`). In a folder that holds several repositories,
start it with the repository's name when the subject belongs to one
(`api-auth-flow`).

**One subject, one file.** If a file on the same subject exists, update it
instead of creating another one. A follow-up question on the same subject is
added to the file: append it to the questions, add a researched line for it, and
merge its findings into the sections, keeping what still holds.

**Format.** Keep the headings below in English so other skills can find the
sections; write the body in the user's language. Write sources as plain
`path:line`, never as markdown links, and give every path from the folder the
file lives in (`api/pom.xml:12` when the file sits next to several
repositories), so the file stays readable from anywhere.

```md
---
title: <Topic>
kind: codebase
repos: [<repo>, <repo>]
summary: <one line: what the note explains>
updated: <date>
---

# <Topic>

**Questions:**
1. <the question>

**Researched:** <date>; <repo> `<short hash>` (<branch>), <repo> `<short hash>` (<branch>)

## Short answer

## How it works

## Key places

## Assessment

## Inconsistencies in the code

## Not confirmed
```

Drop a section that would be empty. The commits tell a later reader how old the
description is; with a follow-up, add a second researched line rather than
overwriting the first. Other skills read this folder: `/dev-skills:research`
uses it as context for a task.

## Completion criteria

The skill is complete only when:

- The question is answered, or you said clearly what you could not find.
- Every statement about the code points to a file and line, and you reopened
  every line the answer cites, the ones subagents reported included.
- Every count in the answer was re-run or is labelled as a subagent's count.
- Judgement, when asked for, sits in "Assessment", apart from the facts.
- The repositories searched are named when there is more than one.
- Nothing was changed except, on request, `docs/codebase/` and `docs/INDEX.md`
  in the folder Claude was started in and, when that folder is inside a
  repository, its local exclude file.
