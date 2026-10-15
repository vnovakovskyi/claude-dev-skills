# The workflow

```text
research → plan → implement → pr
```

## How the workflow keeps Claude from coding too early

The workflow uses a **soft, conversational gate** — no hook, no marker files in
the normal flow. The discipline lives in the skills themselves:

- `plan` produces a **phased plan** in the active case's `plan.md`. Each phase has its own
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
the plan, so work is resumable: re-running `/dev-skills:implement`
picks up at the first unchecked phase.

> If you also want **hard** enforcement — where Claude is *physically* blocked
> from editing code until you approve — there is an optional second plugin. See
> [phase-gate.md](phase-gate.md).

## The main line

Run Claude Code inside your project and start with:

```text
/dev-skills:research <idea, feature, problem, or change to research>
/dev-skills:plan <what should be planned>
```

Review the plan in the case folder, then implement it phase by phase:

```text
/dev-skills:implement <optional: a specific phase from the plan>
```

`implement` implements one phase, runs its checks, ticks its boxes, and pauses
for your manual verification. Tell it to continue when you are ready for the
next phase.

## Questions about the code

```text
/dev-skills:research-codebase <question about the code>
```

`research` thinks about the task. `research-codebase` explains the code as it
is: where something lives, how a flow runs from its entry point to its side
effects, why a line is the way it is (from `git log` and `git blame`). Use it
whenever you want to understand a part of the code, inside the workflow or
outside it.

It is read-only. It answers in the chat, backs every statement with a file and
line, and says what it could not confirm. It describes the code without
suggesting changes unless you ask for them; where the code contradicts itself,
it lists both sides. Ask it how big a change would be, or in what order to do
it, and it gives that judgement in a section of its own, apart from the facts.

When the folder holds several repositories, it names the ones it searched. A
narrow question it answers itself; a broad one it splits between subagents and
checks every line they report before it answers.

Add `save` to the question, or ask after the answer, and it writes
`docs/codebase/<topic>.md` with the commits it looked at, so a later reader can
tell how old the description is. The file goes into the folder you started
Claude in, not into the repository you asked about, so it never shows up in a
diff. When that folder is itself a repository, the skill adds `docs/`
to the repository's local `.git/info/exclude`, which is personal and never
committed. `research` reads that folder as context for a task.

## The optional skills

```text
/dev-skills:architecture <architecture to analyze or design>
/dev-skills:data-model <data model to analyze or design>
```

Use them whenever they help:

- After research, before planning.
- Inside an existing service, to document or review its current architecture.
- Inside an existing service, to review or redesign its data model.
- Before a migration or a refactoring.

## The knowledge base

All skills share one knowledge base: the `docs/` folder of the folder you start
Claude in, never a folder inside your repositories. Start Claude in the folder
that holds your repositories, and the knowledge base covers all of them, so
what was learned in one service is found when you work on another.

```text
docs/
  INDEX.md                         one line per case and note, generated
  .active                          the case in progress
  codebase/<topic>.md              how existing code works (research-codebase)
  cases/<YYYY-MM-DD>-<slug>/
    case.md                        the card: problem, findings, decision, outcome, lessons
    research.md                    research
    plan.md                        the plan
    architecture.md                optional
    data-model.md                  optional
```

A **case** is one subject — a problem, a change, a question — with everything
done about it. It is not a ticket: when the same error turns up in another
service, the work continues in the same case.

- Every skill starts by searching the knowledge base: it reads `INDEX.md` and
  greps the cards for the request's error texts, services, and tickets, and
  reports what it found as "Prior work".
- `research` picks the case, continuing a matching one or creating a new one,
  and writes `docs/.active`.
- `plan`, `architecture`, and `data-model` write into the active case;
  `implement` marks it `in-progress`; `pr` records the pull request, the
  outcome, and the lessons, and marks it `in-review`. A later skill that finds
  the pull request merged marks it `solved`.
- `INDEX.md` is rebuilt from the cards by `plugins/dev-skills/scripts/reindex.sh`
  after every change, so it never drifts from them.

When the folder you start Claude in is itself a repository, the skills list
`docs/` in that repository's personal `.git/info/exclude`, so the knowledge base
never shows up in its changes. They never edit a `.gitignore`.

The full format — the card's fields, statuses, and the search steps — is in
[plugins/dev-skills/references/knowledge-base.md](../plugins/dev-skills/references/knowledge-base.md).

## Opening a pull request

```text
/dev-skills:pr <optional: base branch, then "draft", an issue to link, or what to emphasize>
```

`pr` reads the whole branch against its base, commits what belongs to the
change, pushes the branch, and opens the pull request. If the branch already has
one, it rewrites the description so that it covers the new commits too.

It works only on a working branch and stops at the open pull request. It never
merges, never enables auto-merge, and never pushes into the base: the merge is
always yours.

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

It also keeps to a few limits. It never pushes your work to the default branch
or to the base (if you are on one of them, it creates a branch first), never
force-pushes unless you ask, stages files by name, and stops at the open pull
request without merging it. If the repository has its own pull request template,
`pr` fills that template and makes sure the three questions are still answered.

## Drafting a message

Work comes with messages: questions to the product owner about a ticket, a
status update upward, a handoff to the testers, a request to a colleague.

```text
/dev-skills:draft-message <to whom: name, role, or relation>, <channel>: <what the message is about>
```

Name the recipient (name and role, or how they relate to you), the channel, and
what the message is about. The skill takes the facts from the conversation, so
it fits right after `research` or `research-codebase`. It shapes the length and
tone to the channel and the person, and writes the text the way a person writes
it in that language: no typography a keyboard does not produce, no template
openers and closers, no headings or bold in a message to a person. The rules
describe these habits by what they do, not as word lists, so they work in any
language.

The draft comes back in the chat. The skill never sends, posts, or saves it:
sending is yours.

## Who starts a skill

The workflow skills and `research-codebase` run only when you type the command. Claude never starts
them on its own (`disable-model-invocation: true`). `pr` also starts when you ask
for a pull request in plain words, and `draft-message` when you ask for a
message, an email, or a comment to someone.

Every command carries the plugin's name. Short names such as `plan` or
`research` are easy to collide with, both with built-in commands and with other
skills you have installed. The `dev-skills:` prefix rules that out.
