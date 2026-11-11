---
name: update-memory
description: Update the working memory with what a session learned, so the next session starts from it. Goes through the conversation (decisions, findings, lessons, the user's corrections, work done, open follow-ups) and writes each item once, to the place that owns it - the knowledge base (cases and codebase notes), Claude's memory, or the project's own notes as its instructions describe them. Also corrects entries that went stale and tidies the stores up (duplicates, outdated facts, an overgrown index). Never commits, pushes, or posts. Use when the user asks to save, remember, record, or write down what matters from the work, or to update or tidy up the memory, the notes, or the knowledge base.
argument-hint: '[refresh | optimize] [what to keep, or the subject or store to refresh or tidy]'
---

# Update the working memory

You are running the **Update the working memory** skill.

User request:

`$ARGUMENTS`

## Purpose

A session ends and its context is gone. What was decided, found, learned, and
left open survives only if it was written down, in a place the next session
reads. This skill does that on request, for every store that keeps it — the
knowledge base, Claude's memory, and the project's own notes — in three modes:

- **record** (the default): go through this session and write down what is worth
  keeping.
- **refresh** — the request starts with `refresh`: check what is already stored
  about a subject against the current truth, and correct it.
- **optimize** — the request starts with `optimize`: tidy the stores up, as
  `references/optimize.md` describes.

Text after the mode narrows it: a subject ("the FS-1006 pull request"), a store
("memory"), or one thing to keep ("remember that deploys freeze on Fridays").

## Hard rules

- **Only what is true.** Everything you write comes from this conversation, a
  file, or a tool's output. A fact you could not check is marked as unchecked,
  in the store's own way (for example a `❓`), or left out. Never fill a gap with
  a guess about people, ownership, numbers, or dates.
- **One fact, one place.** Each item is written once, in the store that owns
  it (the table in Step 3); other stores get a link to it, not a copy. This is
  the rule in `../../references/knowledge-base.md` (from this skill's base
  directory), applied to every store.
- **Edit, don't pile up.** Before you write, search the store. Update the entry
  that covers the item instead of adding a second one next to it.
- **The project's rules win.** When the folder's instructions (`CLAUDE.md`,
  `AGENTS.md`, or a note they point to) say where and how notes are kept, follow
  them exactly: their files, sections, templates, tags, and order. Files they
  mark as the user's own, or as kept verbatim, are never restructured.
- **Instruction files only on a yes.** A rule that should change how every
  future session behaves belongs in `CLAUDE.md` or `AGENTS.md`. Show the exact
  lines and where they go, and write them only when the user says yes in their
  own message.
- **Add and correct freely; restructure what the user wrote only on a yes.**
  In the project's notes you may add to an entry, correct a fact that its
  source (the code, the pull request, the ticket, this conversation) shows no
  longer holds, and add a link. Two notes that only disagree with each other
  are listed under **Needs your yes**, not settled by picking one. Merging two entries,
  replacing text that still holds with a link, condensing, moving, or deleting
  text there is proposed under **Needs your yes**, unless the project's rules
  for its notes say otherwise. The knowledge base and Claude's memory are
  written by the skills and by you: tidy them as `references/optimize.md`
  says, but a case is closed with a status, never deleted, and two cases are
  merged only on the user's yes.
- **Nothing secret, nothing personal.** No tokens, passwords, keys, or
  connection strings, and no personal data from logs or databases. Quote an
  error text, not the user or the token it carried.
- **Local only.** This skill writes files. It never commits, pushes, posts,
  sends, or comments anywhere, and starts no new work.

## Step 1 — Find the stores

Find out which of these this session has, and read their entry points:

1. **The knowledge base**: the `docs/` folder of the folder Claude was started
   in, as `../../references/knowledge-base.md` describes. Read `docs/INDEX.md`
   and `docs/.active`.
2. **Claude's memory**: the persistent memory directory that your instructions
   name (Claude Code's auto memory, with `MEMORY.md` as its index), in the
   format those instructions give. Read `MEMORY.md`. When the session has no
   memory directory, skip this store and say so.
3. **The project's own notes**: a notes system that the folder's `CLAUDE.md` or
   `AGENTS.md` describes — a work log, a decision log, a task register, notes
   per service or per person, a "where I stopped" block. Read the instructions
   that describe it, and the entry note they name.
4. **Instruction files**: `CLAUDE.md` and `AGENTS.md` of the folder and of the
   repositories worked on.

The report's **Stores** line (Step 5) says which exist and which do not.

## Step 2 — Collect the items

**record:** go through the whole conversation, the part summarized after a
compaction included. Collect each of these that happened:

- **Work done**: changes, pull requests, reviews, deploys, measurements, with
  their links and the numbers that came out.
- **Decisions**, with the reason and who made them.
- **Findings and lessons**: how something works, what broke and why, what
  misled you, a trap to recognize next time.
- **The user's corrections and confirmed choices**: what they asked you to stop
  doing, do differently, or keep doing, and why.
- **Facts about people and the project** that the code cannot tell: who owns
  what, who decides, deadlines, constraints.
- **Problems found and left**: something broken, risky, or out of date that was
  not fixed here.
- **Open follow-ups**: checks not run, questions unanswered, next steps.
- **Answers to open questions**: an unknown that was marked earlier and is now
  known.

Then check what is already stored: the skills that ran in this session (`pr`,
`review-pr`, `research`, …) may have saved part of it. Keep only what is new
or changed.

Leave out what does not need saving:

- what the code, the git history, the pull request, or the ticket already
  records;
- what mattered only inside this conversation;
- anything secret or personal.

**refresh:** collect what the stores hold about the subject: cards, notes,
memory entries, lines in the project's notes. For each fact, find its source
today: the file and the symbol it names, the pull request's state
(`gh pr view <pr> --json state`), the ticket, the latest conversation.
Collect what is wrong, missing, or settled:

- a fact that no longer holds;
- a case whose pull request is merged;
- an open question that now has an answer;
- a follow-up that is done.

**optimize:** follow `references/optimize.md`, then continue at Step 4.

## Step 3 — Route each item

| The item | Goes to |
|---|---|
| A finding, decision, outcome, or lesson of a task that has a case | the case: its card's `Findings`, `Decision`, `Outcome`, or `Lessons`, details in its other files |
| How existing code works, worth reading again | `docs/codebase/<topic>.md` |
| Work done, problems found, decisions, people, follow-ups that have no case — when the project's notes have a place for it | that place, in its format |
| The user's role, preferences, and corrections; facts about the project or people that no file holds; where to find a dashboard or a document | Claude's memory |
| A rule every future session must follow | an instruction file, on the user's yes |

- When an item belongs to a case, the case owns it. A log in the project's
  notes that keeps items of that kind (a work log, a decision log, a task
  register) gets one line in its own format: the date, the subject, and a link
  to the case, not the reasoning, the numbers, or the details. When the project's rules ask
  for more in that line (an id, the evidence), give it.
- When the project's notes and Claude's memory could both hold an item, the
  project's notes win: the user reads them, and they can be searched. Memory
  then gets a pointer, and only when it changes how you work.
- A task without a case gets a new one only when its subject is worth a card
  (a problem solved, a change made, a question answered). One small fact goes
  to memory or the project's notes instead.
- An item that fits nowhere is listed in the report as not saved, with the
  reason.

## Step 4 — Write

- Write each item in its store's format: the card's sections and frontmatter
  from `../../references/knowledge-base.md`, the memory format from your
  instructions, the project's templates and tags from its instructions.
- A write that a hook or a permission refuses (the phase gate before a plan is
  approved, for example) is not retried another way, not through the shell and
  not through a script. List the item under **Not saved** with the message, so
  it can be saved once the write is allowed.
- Update the entry that covers the item; add a new entry only when none does.
  Remove a marker for an unknown (`❓`) wherever its answer is now written.
- Set the date the store keeps for "last changed" (`updated:` and the like) on
  every file you edit.
- Absolute dates only: "Thursday" becomes `2026-03-05`.
- Write in each store's language: the knowledge base's, the language the
  project's notes are written in, the language memory is already written in.
  English when there is nothing to go by.
- Rebuild the indexes you touched: run `reindex.sh` for the knowledge base, and
  keep one line per entry in `MEMORY.md`.

## Step 5 — Report

In the chat, in the language of the request, and short:

```md
**Stores:** <the stores found in Step 1, and the ones missing>

**Saved**
- <store> · <file, linked> — <what was written or changed, one line>

**Not saved:** <items left out and why, refused writes included, or "nothing">

**Needs your yes:** <proposed instruction-file lines, merges, and deletions, shown in full, or "nothing">
```

## Completion criteria

The skill is complete only when:

- Every item worth keeping is in exactly one store, with links from the others
  where they need them.
- Every edited file has its date updated, and every touched index is rebuilt.
- Nothing was committed, pushed, or posted, and nothing in the project's notes
  or the instruction files was merged, condensed, or deleted without the
  user's yes.
- The user has the short report, with the changes that wait for their yes.
