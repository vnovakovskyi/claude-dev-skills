# A later round

Step 1 of the skill sends you here when the knowledge base already holds a
review of this pull request. Review what changed since it instead of the whole
pull request again:

1. Take the head commit from the first line of the latest review file (for an
   older file without that line, the commit its header names). When it is no
   longer an ancestor of the head (a force-push or a rebase), compare the two
   versions with `git range-diff <old base>..<old head> <new base>..<new head>`;
   when that is unreadable, do a full pass.
2. Read the delta: `git diff <previous head> <head>`, and in full only the files
   it changes. Reviews, comments, and description edits since the previous
   round count as part of it.
3. Check the base branch again (Step 2): what came in since the previous round,
   and whether it still merges cleanly.
4. Re-check every finding of the previous round at the new head: **fixed**,
   **still open**, **answered** (with who answered and whether the answer
   holds), or **obsolete**. A fix is checked like any new code, its tests by
   Step 6.
5. Review the delta by Steps 5–7. Re-check the claims the delta or the new
   description touches, and say that the rest are unchanged.
6. Run the tests the delta touches, and on the merge result when the base
   changed the same modules.

Do a full pass instead when the delta touches most of the pull request, or the
user asks for one.

With no delta (same head, nothing new said), a request to review again means
going deeper: Step 4 again in full, then Steps 5–7 on what the previous round
covered least — paths, inputs, real data shapes, numbers from the running
system.

The review file keeps the shape in `review-file.md`, with a section "Findings of the
previous round" before the new findings, and says what changed since the
previous round in its first lines. The chat summary gives the previous round's
findings as one line of counts (fixed, still open, answered, obsolete) before
the new findings, and names the ones still open.
