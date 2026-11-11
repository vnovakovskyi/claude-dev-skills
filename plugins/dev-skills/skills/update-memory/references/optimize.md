# Tidying the stores up

The `optimize` mode keeps the stores small and true. The work is in the
indexes and the cards first, and in a full file only when an index points at
a problem. Go through the stores named in the request, or all of them.

Fix what the rules in `SKILL.md` allow. Collect the rest under **Needs your
yes**: deleting or merging what the user wrote, and editing an instruction
file.

## Claude's memory

- **The index matches the files.** Every file has one line in `MEMORY.md`, and
  every line points at a file that exists. The index holds pointers only, no
  content, and stays short: Claude Code loads only its first part into each
  session.
- **Duplicates.** Two entries about the same fact become one. Keep the better
  one, merge in what the other adds, delete the other, and fix the links to it.
- **Stale facts.** A file, function, flag, URL, or person that an entry names
  still exists. A date in the past turns a plan into history: reword it or
  drop it. Relative dates ("next week") become absolute ones or go.
- **Copies of other stores.** An entry that repeats a case, a codebase note, or
  the project's notes becomes a pointer to it, or goes when it adds nothing.
- **What does not belong.** Facts the repository or its history already
  records, and anything secret or personal, are deleted.

## The knowledge base

- Run `reindex.sh` and fix every warning it prints: a missing field, a card
  without frontmatter.
- **Cases in `in-review`:** check their pull requests
  (`gh pr view <pr> --json state`). Merged → `solved`, with `Outcome` updated,
  as `../../references/knowledge-base.md` describes. For a plan with phases,
  only when every phase is merged.
- **Cards over about 60 lines,** and summaries over about 250 characters: move
  details into the case's other files and tighten the summary.
- **Two cases about one subject:** link them with `related` both ways. Merging
  them into one, which removes a folder, needs the user's yes.
- **`docs/.active`** names a case that exists and is still open. When it does
  not, say so; the next `research` run sets it.
- **Codebase notes** whose files or symbols no longer exist: mark the stale
  part, with the date you checked.

## The project's own notes

- **Their maintenance rules come first.** When the instructions say how to
  close an item (move it to a "Done" section, never delete it), do that.
- **Answered unknowns.** A `❓` whose answer is written elsewhere is replaced
  with the answer or a link to it.
- **One fact, one place.** The same fact in two notes stays in the note that
  owns it; the other gets a link.
- **Broken links** to notes that were renamed or never written: fix the link,
  or list it.
- **Entry notes** such as a "where I stopped" block or a start page: anything
  older than the notes they summarize is brought up to date or marked as old.
- Files the instructions mark as the user's own, or as kept verbatim, are
  only read, never tidied.

## Report

Use the report from `SKILL.md`, Step 5, with one more line on top:

```md
**Tidied:** <store> — <n merged, n corrected, n deleted, n closed>, …
```
