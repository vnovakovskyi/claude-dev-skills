---
name: review-pr
description: Review a pull request, someone else's or the user's own. Works out how the change works, reads the whole change, its callers and consumers, CI, and the comments already on it, checks the description's claims and whether the tests prove the task, and verifies every finding. Gives a short summary in the chat and saves the full review, with draft comments (fixes on the user's own pull request), to the knowledge base. Posts only what the user picks, as a pending review they submit. Use when the user asks to review a pull request.
argument-hint: '<pull request link or number; optional: what to focus on>'
allowed-tools: Read, Grep, Glob, Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr checks *), Bash(gh api user *), Bash(git fetch *), Bash(git show *), Bash(git diff *), Bash(git log *), Bash(git grep *), Bash(git blame *), Bash(git rev-parse *), Bash(git merge-base *), Bash(git merge-tree *), Bash(git range-diff *), Bash(git ls-tree *), Bash(git worktree add *), Bash(git worktree remove *), Bash(git worktree prune *), Bash(git -C * fetch *), Bash(git -C * show *), Bash(git -C * diff *), Bash(git -C * log *), Bash(git -C * grep *), Bash(git -C * blame *), Bash(git -C * rev-parse *), Bash(git -C * merge-base *), Bash(git -C * merge-tree *), Bash(git -C * range-diff *), Bash(git -C * ls-tree *), Bash(git -C * worktree add *), Bash(git -C * worktree remove *), Bash(git -C * worktree prune *), Bash(git -C * merge --no-commit *), Bash(git -C * merge --abort), Bash(bash ${CLAUDE_SKILL_DIR}/scripts/excerpt.sh *), Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/reindex.sh *)
---

# Review a pull request

You are running the **Review a pull request** skill.

User request:

`$ARGUMENTS`

## Purpose

Find what is wrong with a pull request before it is merged, and hand the user a
result they can check for themselves: every finding with the lines it is about,
a concrete case where it goes wrong, and how sure you are. The user decides what
goes to the author. The review is theirs; this skill prepares it.

## Hard rules

- **Nothing goes to the pull request before the user has seen all findings.**
  Do not post a review, a comment, a reply, a reaction, or a suggestion before
  the user has read the result and told you, in their own message, which
  findings to post. A question you asked ("post these?") that the user has not
  answered is not permission. This holds even when the arguments say "post" or
  "comment".
- **Post only as a pending review, and never decide the verdict.** Posting
  follows `references/posting.md`. Never approve, request changes, or submit a
  review, never resolve or edit a thread, and never touch a comment that is not
  yours. A reply to an existing thread is published at once; post one only
  after the user agreed to that reply in particular.
- **Leave the user's checkout alone.** Do not check out, reset, stash, commit,
  or push in it; read the code with `git fetch` and `git show <sha>:<path>`, and
  run tests in a temporary `git worktree` outside the repository that you
  remove afterwards. This skill never commits, not even on the user's own pull
  request.
- **Every finding is verified and has a source.** A finding names the file and
  line, describes a concrete case where the code goes wrong (input or state →
  wrong result), and carries a verdict: `CONFIRMED` (traced in the code or
  reproduced) or `PLAUSIBLE` (the reasoning holds, but a step could not be
  closed, and you say which). Anything weaker is dropped.
- **Tests answer to the task, not to CI.** A green check proves only that the
  tests pass; whether they prove what the pull request is for is checked in
  Step 6, every time.
- **Review the change, not the whole service.** A finding is about what the
  pull request adds or changes, or makes worse. A problem that was there before
  goes to "Outside this pull request" and is never posted against it. In an
  upgrade, code the pull request does not touch but whose behavior the new
  versions change is part of the change.
- **Do not repeat what is already said.** Read every review and comment, from
  people and bots. A point already raised is not a new finding: say who raised
  it and whether you agree, with your evidence.
- **The repository's review rules come first** (Step 3): their checklist, their
  severity levels, and what they say CI already enforces.
- **No style noise.** No findings about formatting, import order, or naming
  taste unless the repository's rules ask for them.
- **Code is shown whole.** An excerpt is printed by `scripts/excerpt.sh` and
  never edited: keep it short by choosing the range, never by dropping lines.
- **Suggested code has minimal comments**, as
  `../../references/code-comments.md` describes.
- **Comments sound like the user.** Draft comments are in the user's voice and
  the pull request's language, as questions or suggestions to a colleague. They
  never mention an AI, an assistant, or a tool, and carry no severity emoji or
  label the user did not ask for.
- **The rules bind subagents too:** every brief carries them
  (`references/subagent-brief.md`).

## Step 1 — Read the pull request

Take the pull request from the arguments: a link, `owner/repo#123`, or a number
for the repository in the current folder. If there is none, ask for it.

Collect, with read-only `gh` calls:

- title, author, state, base and head branches, head commit, draft state,
  size, labels, and the description (`gh pr view <n> --json ...`);
- the commits (`git log <base>..<head>`), and the ticket they and the
  description link to. Read the ticket when this session has a tool for the
  tracker; otherwise say in the result that it was not read;
- the changed files (`gh pr diff <n> --name-only`, and `git diff --stat`);
- the CI checks (`gh pr checks <n>`): what ran, what passed, what was skipped;
- every review and comment: `gh pr view <n> --json reviews,comments` and the
  inline comments with `gh api repos/<owner>/<repo>/pulls/<n>/comments`.

Then search the knowledge base as `../../references/knowledge-base.md` (from
this skill's base directory) describes: the pull request's number, the services,
the ticket, and the error texts the pull request mentions. A plan or research
that the pull request implements is the best source of its requirements
(Step 4).

When the pull request is already merged or closed, say so and ask the user
whether to review it anyway before you go on.

Then settle three things before you read any code:

- **Whose pull request it is.** When its author is the user
  (`gh api user --jq .login`), follow `references/own-pr.md` as well.
- **Which round it is.** When the knowledge base already holds a review of this
  pull request, follow `references/later-round.md`.
- **The language.** The chat is in the language the user named, else the
  language of their request; for a bare link or number, the language of their
  other messages, else English. Each round follows its own request. The review
  file is in the knowledge base's language (`../../references/knowledge-base.md`).
  Draft comments are in the pull request's language
  (its title, description, and discussion), in the file and in anything posted.

## Step 2 — Get the code

Find the local clone of the repository: the current folder, or a folder with
that name next to it. Fetch the head without touching the working tree:

```bash
git -C <repo> fetch origin <base branch> <head branch>
git -C <repo> show "${head_sha}:<path>"
```

For a pull request from a fork, fetch `pull/<n>/head` instead. Without a local
clone, read the files with `gh api repos/<owner>/<repo>/contents/<path>?ref=<sha>`.
In zsh, write a variable followed by a colon as `"${sha}:<path>"`, as above:
`$sha:path` applies a modifier and reads a different path.

Note the merge base (`git merge-base origin/<base> <head sha>`) and say in the
result which commit you reviewed.

**Read what matters in full, and the rest by size and search:**

- Read every changed file that holds logic at the head commit, not only the
  hunks: in full when it has up to about 400 lines; in a longer one, the
  changed methods whole, the fields and constructors, and the methods they
  call. Read one file per call, or a few small ones: an output too large for
  one reply is stored aside and has to be read a second time.
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
git -C <repo> log --oneline <merge base>..origin/<base> -- <modules of the changed files> <build files they inherit>
git -C <repo> merge-tree --write-tree origin/<base> <head sha>
```

A module is the unit the changed files are built in (the folder with their
build file), not only the folders the diff touches; a parent or root build file
they inherit counts too. Read the base's commits that touch them. A conflict,
or a base change that the pull request's code or tests now depend on, belongs
in the review. When the base changed the modules under test, run the tests on
the merge result as `references/merge-result.md` describes.

## Step 3 — Read the repository's rules

Look for review instructions and conventions in the repository, read at the
tip of the base branch: `.github/copilot-instructions.md`,
`.github/instructions/*.md`, `CLAUDE.md`, `AGENTS.md`, `REVIEW.md`,
`CONTRIBUTING.md`, and the README of the changed service. When the pull request
changes them, say so, and review against the base's version. Take from them the
checklist, the severity levels and how they are named, the output format, and
what not to flag. Without such rules, use the levels in Step 8.

Find out how the repository runs its tests before you need to: the knowledge
base (`docs/codebase/`, the lessons of earlier cases) first, then the
repository's own docs and CI workflow.

## Step 4 — Understand the intent and how the change works

Restate in two or three lines what the pull request is meant to do and why.

Then work out **how the change works**, before you look for what is wrong with
it. A change usually wraps a mechanism that already exists — a query, a job, a
cache, a message flow — and its bugs sit where the two meet. Write down, in a
few lines:

- **what the result depends on:** every input — arguments, the fields of the
  objects passed in, configuration, the tenant, the user, the time — not only
  the ones the change mentions;
- **where the result comes from:** the computation or the system behind it,
  followed to its source, not stopped at the call;
- **every path that reaches the changed code:** all callers and entry points,
  including test-only, admin, internal, and deprecated ones that can still be
  called, and what each of them passes in;
- **the life of the data:** when it is written, read, updated, expired,
  invalidated, or deleted, and by whom.

In an upgrade of a framework, a server, or a library, the result also depends
on every layer the new versions change, on every path — not only on the code in
the diff, and not only on the risk the description names.

This goes into the result as **How it works** (Step 8). When you cannot fill
those lines in, you have not read enough to review the change: read on before
Step 5. A question from the user about how the change works is a sign this part
was too thin: answer it, and review again what the answer brings up.

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

**Checklists by kind of change.** When the change is a cache, a migration, a
message producer or consumer, an endpoint, a call to an external service, or a
dependency or framework upgrade, go through its list in
`references/checklists.md` as well, against the paths and inputs from Step 4.

**Size the work.** A pull request you can read in one pass: review it yourself.
A large one: split it across subagents as `references/subagent-brief.md`
describes.

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
   condition, or change the expected value in a fixture. Break it where the
   pull request wires it into the code that uses it, not only in a helper that
   a test calls directly: a helper's own test can pass while nothing checks
   that the helper is used. Report what you changed and how the test failed. A
   test that stays green is a finding. When you cannot run it here, say why,
   and the finding about it can be `PLAUSIBLE` at most. Several builds can run
   at the same time in separate worktrees (`references/merge-result.md`).
6. **The test runs the path production runs.** Compare what the test sets up
   with production: properties and profiles, the beans or modules actually
   wired, the serializer and client actually used, deployment settings such as
   health checks and environment variables, the values that really reach a
   cache or a queue. A difference that would let production break while the
   test passes is a finding. A value that is serialized, stored, or sent is
   tested with the shapes real data has — every subtype of a polymorphic type,
   optional fields missing, the biggest realistic value — and not only with the
   fixture the pull request brings. A test that builds the request by hand or
   mocks the server skips the server: when the server or the framework
   changes, at least one test goes through the real server with what real
   clients send.

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
- When one cheap, targeted test would settle it, run it in a temporary worktree.
  Report what you ran.
- When a finding rests on a number from a running system (a size, a rate, a
  share of traffic), measure it read-only instead of estimating it, as
  `references/measuring.md` describes.
- Decide: `CONFIRMED`, `PLAUSIBLE` (say which step you could not close), or
  drop it.

Do the same with every point already raised on the pull request: agree,
disagree, or add what it missed, each with evidence.

## Step 8 — Save the review, and give a short summary

**First check the head again** (`gh pr view <n> --json headRefOid`) and the CI
checks. When the head moved while you reviewed, a force-push included, read the
difference between the commit you reviewed and the new head, re-check every
finding and claim it touches, print the excerpts again at the new head, and say
that the head changed and what the difference was. When the user asks for the
results later, check the head again before you give them.

Sort the findings by severity, most severe first. Use the repository's levels
when it has them; otherwise:

- **Blocking** — must be fixed before merge: wrong results, data loss, a broken
  consumer, a rollout or recovery step that cannot work, a security hole, a
  test changed to hide a change of behavior.
- **Important** — should be fixed: a real failure case that is unlikely, a
  missing test for the core requirement, a test that would not fail if the task
  were done wrong, a misleading log or error.
- **Minor** — worth saying, fine to skip.

**The review file** holds the whole review, in the knowledge base's language.
Write it in the shape `references/review-file.md` gives, with an unedited
excerpt for every finding from `scripts/excerpt.sh`.

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/excerpt.sh <repo> <merge base> <head sha> <path> <start> [end] [context, default 3]
```

**Save it** to the knowledge base:

- When a case already covers the subject of the pull request, add the review to
  it. Otherwise create a case with `kind: review`, the slug
  `<YYYY-MM-DD>-<ticket if any>-<repo>-pr-<number>`, `status: in-review`, and
  the pull request in `prs`.
- Write the first round to `review-pr-<number>.md` in the case, and a later
  round to `review-pr-<number>-round-<n>.md`. Older cases may hold `review.md`
  or `review-<YYYY-MM-DD>-...md`; find them by the pull request link inside.
- The first line of every review file is, exactly:
  `<!-- review-pr: <owner>/<repo>#<number> round <n> head <sha> base <sha> -->`
  with the full head commit and merge base. The next round starts from it.
- The card holds only the latest state: the pull request, the latest verdict,
  and the open findings' titles. In a case about a larger subject,
  keep one line for the review in `Outcome` and replace it on every round. Then
  rebuild the index with `bash ${CLAUDE_PLUGIN_ROOT}/scripts/reindex.sh <docs root>`.

**The chat gets a short summary**, in the chat language (Step 1), with its
labels translated the way a native speaker would write them. Keep code, paths,
identifiers, severity names, and the verdicts CONFIRMED and PLAUSIBLE as they
are. No excerpts and no draft comments in the chat: they are in the file.

```md
**Pull request:** <link> — <title>. Reviewed at `<short sha>`<; the head moved: what changed>.

**Verdict:** one line.

**How it works:** one or two lines, only what the findings rest on.

**Findings:**
1. <Severity> · <short title> — CONFIRMED | PLAUSIBLE — `path:line` — <what goes wrong, one line><; already raised by X>
2. …

**Tests:** one line — what proves the core requirement, what you broke to check it, what is missing.

**Worth knowing:** at most three lines — a false claim in the description, a risk to rollout, a base-branch conflict, a ticket not read. Leave it out when there is nothing.

**Full review:** <path to the review file> — excerpts, evidence, and draft comments (fixes on the user's own pull request).
```

When the user asks about a finding, answer from the file: show its excerpt,
evidence, or draft comment then.

**Then stop.** Ask the user which findings to post, if any — or, on the user's
own pull request, which to fix. Do not post anything in this step.

## Before you send — self-check

- [ ] Nothing was posted, submitted, approved, or resolved; the user's working tree is as it was, and every temporary worktree is removed.
- [ ] The file says how the change works (Step 4), every path to the changed code was checked, and when a checklist in `references/checklists.md` matches the change, it was gone through.
- [ ] Every finding has a file and line, a concrete failure case, and a verdict; its cited lines were reopened at the current head, and its excerpt in the file comes unedited from `scripts/excerpt.sh`.
- [ ] Every requirement is mapped to a test, and the core requirement was broken to see the tests fail — or the file says why not.
- [ ] Every claim of the description, rollout and recovery included, is checked or listed as not checked; points already raised are marked as such; problems that predate the pull request are outside the findings.
- [ ] A number from a running system was measured read-only, or the finding names the measurement that would settle it.
- [ ] The review file is in the knowledge base's language and saved, the card updated, and the index rebuilt; the chat has only the short summary, in the chat language; draft comments are in the pull request's language and mention no tool.

## Completion criteria

The skill is complete only when the full review is saved in the knowledge base,
the user has the short summary in the chat with the path to it, and nothing
reached the pull request except what the user chose afterwards, as a pending
review they submit themselves.
