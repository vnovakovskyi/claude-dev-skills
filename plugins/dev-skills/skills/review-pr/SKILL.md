---
name: review-pr
description: Review someone's pull request and show the user every finding before anything reaches the pull request. Reads the whole change, the code around it, its consumers in other services, the CI checks, and the comments already on it; checks the description's claims against the code; verifies each finding and drops the ones that do not hold. Returns the findings in the chat and saves them to the knowledge base, each with a draft comment. Posts nothing until the user has read them and chosen what to post, and then only as a pending review that the user submits. Use when the user asks to review a pull request.
argument-hint: '<pull request link or number; optional: what to focus on>'
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(git fetch:*), Bash(git show:*), Bash(git diff:*), Bash(git log:*), Bash(git grep:*), Bash(git blame:*), Bash(git rev-parse:*), Bash(git merge-base:*)
---

# Review a pull request

You are running the **Review a pull request** skill.

User request:

`$ARGUMENTS`

## Purpose

Find what is wrong with a pull request before it is merged, and hand the user a
list they can check for themselves: every finding with the lines it is about, a
concrete case where it goes wrong, and how sure you are.

The user reads the list, checks it, and decides what goes to the author. The
review is theirs. This skill prepares it.

## Hard rules

- **Nothing goes to the pull request before the user has seen all findings.**
  The review ends with the findings in the chat and in the knowledge base. Do not
  post a review, a comment, a reply, a reaction, or a suggestion before the user
  has read the list and told you, in their own message, which findings to post.
  A question you asked ("post these?") that the user has not answered is not
  permission. This holds even when the arguments say "post" or "comment": show
  the findings first.
- **Post only as a pending review, and never decide the verdict.** When the user
  picks findings to post, create a pending review (Step 8) that only they can
  see until they submit it on GitHub. Never approve, request changes, or submit
  a review, never resolve or edit a thread, and never touch a comment that is not
  yours. A reply to an existing thread is published at once on GitHub; post one
  only after the user agreed to that reply in particular.
- **Leave the user's checkout alone.** Do not check out, reset, stash, commit,
  or push in the user's working tree. Read the pull request's code with
  `git fetch` and `git show <sha>:<path>`. When a test has to run, run it in a
  temporary `git worktree` outside the repository and remove the worktree
  afterwards.
- **Every finding is verified and has a source.** A finding names the file and
  line, describes a concrete case where the code goes wrong (input or state →
  wrong result), and carries a verdict: `CONFIRMED` (you traced it in the code or
  reproduced it) or `PLAUSIBLE` (the reasoning holds, but you could not close
  every step, and you say which). Anything weaker is dropped.
- **Review the change, not the whole service.** A finding is about what the
  pull request adds or changes, or about something it makes worse. A problem
  that was there before goes to a separate section, "Outside this pull request",
  and is never posted as a finding against it.
- **Do not repeat what is already said.** Read every review and comment on the
  pull request, from people and bots. A point that is already raised is not a
  new finding: say who raised it and whether you agree, with your evidence.
- **The repository's review rules come first.** When the repository has review
  instructions (Step 3), use their checklist and their severity levels, and
  skip what they say CI already enforces.
- **No style noise.** No findings about formatting, import order, or naming
  taste unless the repository's rules ask for them. A finding has to matter to
  someone who runs or maintains the code.
- **Comments sound like the user.** Draft comments are written in the user's
  voice, in the pull request's language, as questions or suggestions to a
  colleague. They never mention an AI, an assistant, or a tool, and they carry
  no severity emoji or label the user did not ask for.
- **The rules bind subagents too.** A subagent does not see this skill. Every
  brief you give one carries these rules (see `references/subagent-brief.md`).

## Step 1 — Read the pull request

Take the pull request from the arguments: a link, `owner/repo#123`, or a number
for the repository in the current folder. If there is none, ask for it.

Collect, with read-only `gh` calls:

- title, author, base and head branches, head commit, draft state, size, labels,
  and the description (`gh pr view <n> --json ...`);
- the commits (`git log <base>..<head>`), and the ticket they and the
  description link to. Read the ticket when the user has a way to open it;
- the changed files and the diff (`gh pr diff <n>`);
- the CI checks (`gh pr checks <n>`): what ran, what passed, what was skipped;
- every review and comment: `gh pr view <n> --json reviews,comments` and the
  inline comments with `gh api repos/<owner>/<repo>/pulls/<n>/comments`.

Then search the knowledge base as `../../references/knowledge-base.md` (from
this skill's base directory) describes: the services, the ticket, and the error
texts the pull request mentions. An earlier review of the same pull request is
the starting point for this one (Step 7).

## Step 2 — Get the code

Find the local clone of the repository: the current folder, or a folder with
that name next to it. Fetch the head without touching the working tree:

```bash
git -C <repo> fetch origin <head branch>
git -C <repo> show <head sha>:<path>
```

For a pull request from a fork, fetch `pull/<n>/head` instead. Without a local
clone, read the files with `gh api repos/<owner>/<repo>/contents/<path>?ref=<sha>`.

Read every changed file in full at the head commit, not only the hunks. Note
the merge base (`git merge-base origin/<base> <head sha>`) and say in the
result which commit you reviewed.

## Step 3 — Read the repository's rules

Look for review instructions and conventions in the repository:
`.github/copilot-instructions.md`, `.github/instructions/*.md`, `CLAUDE.md`,
`AGENTS.md`, `REVIEW.md`, `CONTRIBUTING.md`, and the README of the changed
service. Take from them the checklist, the severity levels and how they are
named, the output format, and what not to flag. Without such rules, use the
levels in Step 7.

## Step 4 — Understand the intent

Restate in two or three lines what the pull request is meant to do and why.
Then list the **claims** the description makes, because each one is something to
check against the code:

- behavior: "only X is sent", "nothing changes for Y";
- numbers: limits, sizes, counts, timings;
- impact: "service Z needs no change", "no migration needed";
- rollout and recovery: release order, data backfills, "after the release,
  re-run X", feature flags, rollback.

A rollout or recovery step that the new code makes impossible is one of the
most expensive mistakes a review can catch, and the diff does not show it.

## Step 5 — Review

Go through the change along these lines. Skip the ones that do not apply.

1. **Correctness.** Edge cases: empty, null, one, exactly at a limit, above it,
   duplicates. Comparisons and equality (types, formats, case). Off-by-one in
   splits and pages. What happens on the second run of the same input.
2. **State and ordering.** Reads and writes that are not in one transaction;
   check-then-act between two requests or two instances; the order of a write
   and the message or call that announces it; what is left behind when the
   process stops halfway.
3. **Failure and retry.** Which exceptions are caught and which escape; what a
   retry repeats and whether that is safe (idempotency, deduplication ids,
   partial success); what the user or the caller sees when it fails; whether a
   failure can still be repaired afterwards.
4. **Contracts and consumers.** Every changed method, endpoint, message, event,
   field, or schema: search the whole repository, and the other repositories in
   the folder, for its callers and consumers, and check they still work.
5. **Data.** Migrations, defaults for existing rows, column types and lengths,
   indexes for new queries, the size of what is read or sent.
6. **Security.** Input validation, authorization on new endpoints, secrets, and
   personal data in logs.
7. **Tests.** Do the tests check the behavior the description claims, or only
   that the code runs? Which case from steps 1–3 has no test? Was an existing
   test weakened or deleted rather than updated?
8. **Description against code.** Each claim from Step 4: true, false, or not
   checkable from here.

**Size the work.** A pull request you can read in one pass: review it yourself.
A large one (many services, many hundreds of lines): split it into 2–4 areas
that do not overlap, by service or layer, and give each to a subagent with the
brief in `references/subagent-brief.md`. Tell the user in one line how you split
it. While subagents run, do not review their areas yourself.

Write down every candidate finding with its file and line as you go. Do not
filter yet.

## Step 6 — Verify

For each candidate, try to prove it wrong before you keep it:

- Reopen the cited lines at the head commit and make sure they say what the
  finding says. Subagents' line numbers can be wrong.
- Follow the path from the entry point to the failure: callers, transactions,
  configuration, the consumer on the other side. Look for a guard elsewhere that
  already prevents it.
- Check whether a test or a CI check already covers the case.
- When one cheap, targeted test would settle it, run it in a temporary worktree
  (see Hard rules). Report what you ran.
- Decide: `CONFIRMED`, `PLAUSIBLE` (say which step you could not close), or
  drop it.

Do the same with every point already raised on the pull request: agree,
disagree, or add what it missed, each with evidence.

## Step 7 — Show the findings

**First check the head again** (`gh pr view <n> --json headRefOid`) and the CI
checks. When the head moved while you reviewed, a force-push included, read the
difference between the commit you reviewed and the new head, re-check every
finding and claim it touches, print the excerpts again at the new head, and say
in the result that the head changed and what the difference was. When the
user asks for the results later, check the head again before you give them.

Write in the language the user asked in. Draft comments are in the pull
request's language.

Sort the findings by severity, most severe first. Use the repository's levels
when it has them; otherwise:

- **Blocking** — must be fixed before merge: wrong results, data loss, a broken
  consumer, a rollout or recovery step that cannot work, a security hole.
- **Important** — should be fixed: a real failure case that is unlikely, a
  missing test for the core claim, a misleading log or error.
- **Minor** — worth saying, fine to skip.

Use this shape:

```md
**Pull request:** <link> — <title>, by <author>. Reviewed at `<short sha>` (merge base `<short sha>`).

**What it does:** 2–3 lines.

**CI:** what passed, what was skipped, what you ran yourself.

**Already on the pull request:** who reviewed and what they raised, in one line each.

**Verdict:** one line — mergeable as is, after the blocking findings, or needs rework.

### Findings

#### 1. <Severity> · <short title> — CONFIRMED | PLAUSIBLE
**[path/to/file.ext, lines 40–42](<link to the lines at the head commit>)** · inline: yes | no

```diff
     37 │         unchanged context line
     38 │         unchanged context line
+    40 │         line the pull request added or changed
+    41 │         line the pull request added or changed
     42 │         unchanged line the finding is also about
```

- **Problem:** what is wrong, in one or two sentences.
- **When it goes wrong:** the concrete input or sequence, and the wrong result.
- **Evidence:** the lines and the trace that show it.
- **Suggestion:** the smallest change that fixes it; options when there are several.
- **Already raised:** by whom, and whether you agree — or "no".
- **Draft comment:**
  > The text to post, in the user's voice.

### Description claims
- <claim> — true | false | not checked, with the source.

### Outside this pull request
- Problems that were there before, one line each.

### Checked and fine
- What you looked at and found correct, one line each, so the user knows it was covered.

**Prior work:** cases from the knowledge base, or "none found".
```

**Show the code of every finding**, the way a review comment on GitHub shows
it: the lines the finding is about, with a few lines of context above, each with
its line number at the head commit. Do not retype the code; print it with the
script next to this skill:

```bash
bash <skill dir>/scripts/excerpt.sh <repo> <merge base> <head sha> <path> <start> [end] [context, default 3]
```

It marks the lines the pull request added or changed with `+`, so a `diff`
block colours them, and prints on stderr whether the range sits inside the
diff (`inline: yes`) — only then can it carry an inline comment in Step 8.
Pick the range the comment would be attached to: the line where the problem
is, not the whole method. Keep an excerpt under about 15 lines; for a longer
range show its first and last lines and cut the middle with `…`. When a finding
rests on a second place (the transaction boundary, the consumer, the caught
exception), give that place a short excerpt of its own under **Evidence**. A
finding about something that is not code (commits, the description) has no
excerpt; say where it is instead.

Link a source to the head commit on the host
(`https://github.com/<owner>/<repo>/blob/<head sha>/<path>#L42`): the local
checkout is usually on another branch, so a local link would open other code.
Use `path:line` where links do not render. Name the repository for a file in
another one.

**Save the review** to the knowledge base, so the user can re-read it and a
later round can compare with it:

- When a case already covers the subject of the pull request, add the review to
  it. Otherwise create a case with `kind: review`, the slug
  `<YYYY-MM-DD>-<ticket if any>-<repo>-pr-<number>`, `status: in-review`, and
  the pull request in `prs`.
- Write the findings in the shape above to `review.md` in the case, and a later
  round on the same pull request to `review-<YYYY-MM-DD>-<subject>.md`. A later
  round starts from the previous one and says, for each earlier finding,
  whether it is fixed, still open, or answered.
- Keep the card short: the pull request, the verdict, and the findings' titles.
  Rebuild the index as the reference describes.

**Then stop.** End with the path to the saved review, and ask the user which
findings to post, if any. Do not post anything in this step.

## Step 8 — Post what the user chose

Only after the user has told you which findings to post, and with the wording
they approved:

1. Show the final text of every comment once more when the user changed
   anything, and wait for their yes.
2. Check that the user has no pending review on this pull request already
   (`gh api repos/<owner>/<repo>/pulls/<n>/reviews` and look for `PENDING`).
   GitHub allows one; if there is one, stop and tell the user.
3. Create one pending review on the head commit. Leave out `event`, so the
   review stays pending:

   ```bash
   gh api --method POST repos/<owner>/<repo>/pulls/<n>/reviews --input <file.json>
   ```

   with `{"commit_id": "<head sha>", "body": "<summary, if the user wants one>",
   "comments": [{"path": "<path>", "start_line": <start>, "line": <end>, "side": "RIGHT", "body": "<text>"}]}`.
   Attach each comment to the same lines its excerpt shows; drop `start_line`
   for a single line. An inline comment works only on lines inside the diff
   (`inline: yes`). A finding about lines outside it goes into the review body
   with a link to the lines.
   Write the JSON to a temporary file outside the repository.
4. Give the user the pull request link and tell them the review is pending:
   they open "Files changed", read it there, and submit it with the verdict they
   choose. You never submit it.

## Before you send — self-check

- [ ] Nothing was posted to the pull request before the user chose what to post, and nothing was submitted, approved, or resolved.
- [ ] The user's working tree is as it was; any temporary worktree is removed.
- [ ] Every finding has a file and line, a concrete failure case, and a verdict, and its cited lines were reopened at the head commit.
- [ ] Every finding about code shows its lines as an excerpt printed by `scripts/excerpt.sh`, not retyped, with whether it can be an inline comment.
- [ ] The head commit in the result is the pull request's head right now, and the CI status is current.
- [ ] Points already raised on the pull request are marked as such, not presented as new.
- [ ] Every claim of the description is checked or listed as not checked, including its rollout and recovery steps.
- [ ] Problems that predate the pull request are in "Outside this pull request", not in the findings.
- [ ] Draft comments read as the user's own and mention no tool.
- [ ] The review is saved in the knowledge base and the index is rebuilt.

## Completion criteria

The skill is complete only when:

- The user has the findings in the chat, sorted by severity and verified, with
  draft comments, and the path to the saved review.
- Nothing reached the pull request unless the user chose it afterwards, and
  then only as a pending review they submit themselves.
