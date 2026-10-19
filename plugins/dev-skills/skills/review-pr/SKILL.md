---
name: review-pr
description: Review a pull request, someone else's or the user's own, and show the user every finding before anything reaches it. Reads the whole change, the code around it, its consumers in other services, the CI checks, the comments already on it, and what changed on the base branch since; checks the description's claims against the code and the tests against the task, not against CI; verifies each finding and drops the ones that do not hold. A later round on the same pull request reviews only what changed since the previous one. Returns the findings in the chat and saves them to the knowledge base, each with a draft comment, or with a fix when the pull request is the user's own. Posts nothing until the user has read them and chosen what to post, and then only as a pending review that the user submits. Use when the user asks to review a pull request.
argument-hint: '<pull request link or number; optional: what to focus on>'
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh api user:*), Bash(git fetch:*), Bash(git show:*), Bash(git diff:*), Bash(git log:*), Bash(git grep:*), Bash(git blame:*), Bash(git rev-parse:*), Bash(git merge-base:*), Bash(git merge-tree:*), Bash(git range-diff:*), Bash(git ls-tree:*)
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
  picks findings to post, create a pending review that only they can see until
  they submit it on GitHub (`references/posting.md`). Never approve, request
  changes, or submit a review, never resolve or edit a thread, and never touch a
  comment that is not yours. A reply to an existing thread is published at once
  on GitHub; post one only after the user agreed to that reply in particular.
- **Leave the user's checkout alone.** Do not check out, reset, stash, commit,
  or push in the user's working tree. Read the pull request's code with
  `git fetch` and `git show <sha>:<path>`. When a test has to run, run it in a
  temporary `git worktree` outside the repository and remove the worktree
  afterwards. This skill never commits, not even on the user's own pull request.
- **Every finding is verified and has a source.** A finding names the file and
  line, describes a concrete case where the code goes wrong (input or state →
  wrong result), and carries a verdict: `CONFIRMED` (you traced it in the code or
  reproduced it) or `PLAUSIBLE` (the reasoning holds, but you could not close
  every step, and you say which). Anything weaker is dropped.
- **Tests answer to the task, not to CI.** A green check proves only that the
  tests pass. Whether they prove what the pull request is for is checked
  separately, every time (Step 6).
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
- **Code is shown whole.** An excerpt is printed by `scripts/excerpt.sh` and
  never edited: no lines cut out, none retyped. Keep it short by choosing the
  range, never by dropping lines from it.
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
- the changed files (`gh pr diff <n> --name-only`, and `git diff --stat`);
- the CI checks (`gh pr checks <n>`): what ran, what passed, what was skipped;
- every review and comment: `gh pr view <n> --json reviews,comments` and the
  inline comments with `gh api repos/<owner>/<repo>/pulls/<n>/comments`.

Then search the knowledge base as `../../references/knowledge-base.md` (from
this skill's base directory) describes: the pull request's number, the services,
the ticket, and the error texts the pull request mentions. A plan or research
that the pull request implements is the best source of its requirements
(Step 4).

Then settle three things before you read any code:

- **Whose pull request it is.** When its author is the user
  (`gh api user --jq .login`), follow "The user's own pull request" below as
  well.
- **Which round it is.** When the knowledge base already holds a review of this
  pull request, this is a later round: follow "A later round" below, which
  replaces a full pass with a review of what changed.
- **The language.** Write the review in English, unless the user names another
  language for it. Draft comments are in the pull request's language.

## Step 2 — Get the code

Find the local clone of the repository: the current folder, or a folder with
that name next to it. Fetch the head without touching the working tree:

```bash
git -C <repo> fetch origin <base branch> <head branch>
git -C <repo> show "${head_sha}:<path>"
```

For a pull request from a fork, fetch `pull/<n>/head` instead. Without a local
clone, read the files with `gh api repos/<owner>/<repo>/contents/<path>?ref=<sha>`.
In zsh, write a variable followed by a colon as `${sha}:path`: `$sha:path`
applies a modifier and reads a different path.

Note the merge base (`git merge-base origin/<base> <head sha>`) and say in the
result which commit you reviewed.

**Read what matters in full, and the rest by size and search:**

- Read every changed file that holds logic in full at the head commit, not only
  the hunks. Read one file per call, or a few small ones: an output too large
  for one reply is stored aside and has to be read a second time.
- Fixtures, snapshots, generated code, lockfiles, and translations: look at
  `git diff --stat` and their first lines. Open one in full when a finding or a
  test check depends on its content.
- The code around the change (callers, configuration, the consumer on the other
  side): find it with `git grep` on names, signatures, and annotations, then
  read only the parts you need.
- Output of builds and tests: filter it to the summary and the failures.

**Check the base branch.** The pull request will be merged into the base as it
is now, not as it was at the merge base:

```bash
git -C <repo> log --oneline <merge base>..origin/<base> -- <folders of the changed files>
git -C <repo> merge-tree --write-tree origin/<base> <head sha>
```

Read the base's commits that touch the same folders or the same build files.
A conflict, or a base change that the pull request's code or tests now depend
on, belongs in the review (CI, or a finding when it breaks something). When the
base changed the modules under test, run the tests on the merge result in a
temporary worktree (Step 7).

## Step 3 — Read the repository's rules

Look for review instructions and conventions in the repository:
`.github/copilot-instructions.md`, `.github/instructions/*.md`, `CLAUDE.md`,
`AGENTS.md`, `REVIEW.md`, `CONTRIBUTING.md`, and the README of the changed
service. Take from them the checklist, the severity levels and how they are
named, the output format, and what not to flag. Without such rules, use the
levels in Step 8.

Find out how the repository runs its tests before you need to: the knowledge
base (`docs/codebase/`, the lessons of earlier cases) first, then the
repository's own docs and CI workflow.

## Step 4 — Understand the intent

Restate in two or three lines what the pull request is meant to do and why.
Then list the **requirements** — what the change must do, from the ticket, its
acceptance criteria, the plan, and the description — because Step 6 traces
every one of them to a test.

Then list the **claims** the description makes, because each one is something
to check against the code:

- behavior: "only X is sent", "nothing changes for Y";
- numbers: limits, sizes, counts, timings;
- impact: "service Z needs no change", "no migration needed";
- rollout and recovery: release order, data backfills, "after the release,
  re-run X", feature flags, rollback.

A rollout or recovery step that the new code makes impossible is one of the
most expensive mistakes a review can catch, and the diff does not show it.

## Step 5 — Review the code

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
7. **Description against code.** Each claim from Step 4: true, false, or not
   checkable from here.

**Size the work.** Count the changed lines of logic, not of fixtures,
snapshots, generated code, or lockfiles. A pull request you can read in one
pass: review it yourself. A large one (many services, many hundreds of lines of
logic): split it into 2–4 areas that do not overlap, by service or layer, and
give each to a subagent with the brief in `references/subagent-brief.md`. Tell
the user in one line how you split it. While subagents run, do not review their
areas yourself. Step 6 stays with you.

Write down every candidate finding with its file and line as you go. Do not
filter yet.

## Step 6 — Check the tests against the task

Do this whenever the pull request adds or changes tests, and whenever it
changes behavior: a change of behavior without a test is itself something to
report. The question is not whether the tests pass, but whether they would fail
if the task were done wrong.

1. **Every requirement has a test that proves it.** Map each requirement from
   Step 4 to the test that proves it (`path:line`), and say whether it proves
   it fully, partly, or not at all. A requirement with no test that proves it
   is a finding; for the pull request's core requirement it is at least
   Important. A test that maps to no requirement is worth a line: it may test
   what the code does rather than what it should do.
2. **Expected values come from the task, not from the code.** Look at where
   each expected value comes from: the ticket, a specification, real data, or
   the current output of the code under test. A value copied from the code's
   own output proves only that the code still does what it does. That is right
   for a regression test that pins today's behavior on purpose, and the pull
   request must say so. For a new feature or a fix it is a finding.
3. **No signs of a test bent to pass.** Look for:
   - assertions weakened to what always holds: only the status, `isNotNull`,
     `any()` matchers, a size instead of the content;
   - tautologies: a mock returns exactly what the test then asserts, so the
     code between them is never tested; a mock left to return null, so the
     response checked is empty;
   - tests skipped, disabled, or marked flaky; exceptions caught and ignored;
     timeouts, tolerances, or retries raised;
   - a test that bypasses the part it claims to check: a mocked filter, a
     replaced serializer, a hand-built object instead of the real wiring.
4. **Existing tests changed with the code have a reason.** Read the diff of
   every existing test the pull request changes or deletes. Each changed or
   removed assertion needs a reason that traces back to a changed requirement.
   An expectation changed so that the test passes again, without such a reason,
   is a finding; it is Blocking when the description says the behavior did not
   change.
5. **The tests fail when the task is undone.** For the core requirement, break
   it in a temporary worktree and run the tests: revert the fix, flip the
   condition, or change the expected value in a fixture. Report what you
   changed and how the test failed. A test that stays green is a finding.
   When you cannot run it here, say why, and the finding about it can be
   `PLAUSIBLE` at most.
6. **The test runs the path production runs.** Compare what the test sets up
   with production: properties and profiles, the beans or modules actually
   wired, the serializer and client actually used, deployment settings such as
   health checks and environment variables, the values that really reach a
   cache or a queue. A difference that would let production break while the
   test passes is a finding.

Also check that the tests are deterministic: no dependence on the clock,
randomness, the order of a set or map, the network, or another test's state.

## Step 7 — Verify

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

## Step 8 — Show the findings

**First check the head again** (`gh pr view <n> --json headRefOid`) and the CI
checks. When the head moved while you reviewed, a force-push included, read the
difference between the commit you reviewed and the new head, re-check every
finding and claim it touches, print the excerpts again at the new head, and say
in the result that the head changed and what the difference was. When the
user asks for the results later, check the head again before you give them.

Sort the findings by severity, most severe first. Use the repository's levels
when it has them; otherwise:

- **Blocking** — must be fixed before merge: wrong results, data loss, a broken
  consumer, a rollout or recovery step that cannot work, a security hole, a
  test changed to hide a change of behavior.
- **Important** — should be fixed: a real failure case that is unlikely, a
  missing test for the core requirement, a test that would not fail if the task
  were done wrong, a misleading log or error.
- **Minor** — worth saying, fine to skip.

Use this shape:

```md
**Pull request:** <link> — <title>, by <author>. Reviewed at `<short sha>` (merge base `<short sha>`).

**What it does:** 2–3 lines.

**CI:** what passed, what was skipped, what you ran yourself. The base branch: commits since the merge base that touch the same code, and whether it merges cleanly.

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

### Tests against the task
| Requirement | Test | Proves it |
|---|---|---|
| <requirement> | <path:line> | fully / partly / no — why |

- Where the expected values come from.
- What you broke to check the tests fail, and how they failed — or why you could not.

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
its line number at the head commit. Print it with the script next to this skill:

```bash
bash <skill dir>/scripts/excerpt.sh <repo> <merge base> <head sha> <path> <start> [end] [context, default 3]
```

It marks the lines the pull request added or changed with `+`, so a `diff`
block colours them, and prints on stderr whether the range sits inside the
diff (`inline: yes`) — only then can it carry an inline comment. Pick the range
the comment would be attached to: the line where the problem is and the lines
the reader needs to see it, not the whole method. When a finding rests on a
second place (the transaction boundary, the consumer, the caught exception),
give that place an excerpt of its own under **Evidence** instead of widening
the first one. Never cut lines out of the script's output: when the lines that
matter are many, show them all. A finding about something that is not code
(commits, the description) has no excerpt; say where it is instead.

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
- Write the first round to `review.md` in the case, and a later round to
  `review-<YYYY-MM-DD>-round-<n>.md`. Each file names the head commit it
  reviewed in its first line; the next round starts from it.
- The card holds only the latest state: the pull request, the latest verdict,
  and the open findings' titles. In a case about a larger subject, keep one
  line for the review in `Outcome` and replace it on every round instead of
  appending to it; the history lives in the review files. Rebuild the index as
  the reference describes.

**Then stop.** End with the path to the saved review, and ask the user which
findings to post, if any — or, on the user's own pull request, which to fix. Do
not post anything in this step.

## The user's own pull request

When the user wrote the pull request, review it with the same rules and the
same rigor: the description's claims and the tests are checked as if someone
else wrote them. What changes is the outcome:

- No draft comments: a finding ends with **Fix:** — the concrete change, in the
  file and lines it touches — in place of **Draft comment**.
- Nothing is posted, not even a pending review.
- The review ends by asking which findings to fix. Fixing is a separate step,
  done only on the user's word: commit on the pull request's branch through
  `/dev-skills:pr`, which also updates the description when the change makes it
  wrong (counts, claims, how to verify). This skill itself never commits.

## A later round

When the knowledge base already holds a review of this pull request, review what
changed since it instead of the whole pull request again:

1. Take the head commit the latest review file names. When it is no longer an
   ancestor of the head (a force-push or a rebase), compare the two versions
   with `git range-diff <old base>..<old head> <new base>..<new head>`; when
   that is unreadable, do a full pass.
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
user asks for one. The result keeps the shape of Step 8, with a section
"Findings of the previous round" before the new findings, and says what changed
since the previous round in its first lines.

## Before you send — self-check

- [ ] Nothing was posted to the pull request before the user chose what to post, and nothing was submitted, approved, or resolved.
- [ ] The user's working tree is as it was; any temporary worktree is removed.
- [ ] Every finding has a file and line, a concrete failure case, and a verdict, and its cited lines were reopened at the head commit.
- [ ] Every finding about code shows its lines as an excerpt printed by `scripts/excerpt.sh`, unedited, with whether it can be an inline comment.
- [ ] Every requirement is mapped to a test, the source of the expected values is named, and the core requirement was broken to see the tests fail — or the result says why not.
- [ ] The head commit in the result is the pull request's head right now, the CI status is current, and the base branch was checked.
- [ ] Points already raised on the pull request are marked as such, not presented as new.
- [ ] Every claim of the description is checked or listed as not checked, including its rollout and recovery steps.
- [ ] Problems that predate the pull request are in "Outside this pull request", not in the findings.
- [ ] Draft comments read as the user's own and mention no tool; on the user's own pull request, findings carry a fix instead.
- [ ] A later round reports every finding of the previous round as fixed, still open, answered, or obsolete.
- [ ] The review is saved in the knowledge base and the index is rebuilt.

## Completion criteria

The skill is complete only when:

- The user has the findings in the chat, sorted by severity and verified, with
  draft comments or fixes, the tests checked against the task, and the path to
  the saved review.
- Nothing reached the pull request unless the user chose it afterwards, and
  then only as a pending review they submit themselves.
