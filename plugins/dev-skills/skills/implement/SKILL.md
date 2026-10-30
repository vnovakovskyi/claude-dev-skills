---
name: implement
description: Main workflow phase 3. Implement one phase at a time from the plan of the active case. Works out which phases are already done from the plan, the card, and the pull requests; starts the phase on a fresh branch from the base; runs its automated checks; hands off to the pr skill when the user agrees; then pauses for human verification before the next phase. Reads plans written in any language.
argument-hint: "<optional: a specific phase from the plan>"
disable-model-invocation: true
---

# Phase: Implement

You are running the **Implementation** phase for the user's request.

User request / target task:

`$ARGUMENTS`

## Purpose

Implement the next **phase** from the case's plan — one phase at a time, one
branch and one pull request per phase — without drifting into uncontrolled
scope expansion.

## The knowledge base

Read `../../references/knowledge-base.md` (from this skill's base directory)
first. The case is the one named in `$ARGUMENTS`, or else the one in
`docs/.active`; its plan is the newest `plan*.md` in `docs/cases/<slug>/`.
Below, "the plan" means that file, and "the card" means the case's `case.md`.

## Hard rules

- Do **not** start implementation if the case has no plan. Ask the user
  to run `/dev-skills:plan` first.
- Implement **only one phase per run**, unless the user explicitly asks you to
  continue through multiple phases.
- **Never redo a phase that may already be done.** Work out the state of every
  phase first (see "Reconcile the progress"), and ask when the sources disagree.
- **Every phase that changes code starts on its own new branch** from an
  up-to-date base. Never commit a phase onto the base, onto another phase's
  branch, or onto a branch whose pull request is merged or closed.
- **Never discard work.** No `git stash`, `git reset --hard`, `git checkout --
  <file>`, `git clean`, or force-push unless the user asks for that command.
- Do not silently redesign the architecture.
- Do not add extra features because they seem useful.
- **Minimal comments.** The code explains itself; write a comment only for what
  it cannot say, as `../../references/code-comments.md` describes.
- Update documentation if implementation differs from the plan.
- Run the phase's automated checks, or explain why they cannot be run.
- **Ask before every outward action**: pushing a branch, opening a pull
  request, adding a label or a reviewer, commenting on or closing a pull
  request, a production release, a message, a shared setting — anything others
  would see. Wait for the user's yes for each.
- **Pause after each phase** and wait for the user before starting the next one.
- Do not check off **manual** criteria yourself — only the user confirms those.

## Reading the plan

A plan follows the structure of the `/dev-skills:plan` template, but it can be
written in any language, and its headings and labels can use any wording.
Never look for a part by its label, in English or in any other language.
Recognize each part by what it says and where it sits in the phase. The names
below are this skill's own names for the parts. They are not words to search
for.

| Part | How to recognize it |
|---|---|
| Dependencies | Names other phases by number that must be done before this one |
| Parallel phases | Names other phases that may be worked on at the same time |
| Outward actions | Actions other people see: pull requests, releases, messages, shared settings |
| Rollback | Says how to undo the phase |
| Automated criteria | Checkboxes whose result a command decides |
| Manual, before merge | Checkboxes a person confirms while the change is not merged yet |
| Manual, after merge | Checkboxes a person confirms where the merge itself deploys (a test or staging environment), before the next phase or the production release |
| Manual, after rollout | Checkboxes a person confirms once the change is deployed to production, often after some time |
| Open questions | A table of questions, each naming the phase it blocks |
| Common checks | A block outside any single phase that lists checks, often with short ids, which phases refer to |
| Repeated phases | A recipe written once, followed by a table with one row per phase number |

- A list of manual checks that does not say whether it is for before the merge
  or after the rollout counts as before the merge.
- When a phase refers to common checks by id, the phase uses those checks with
  the phase's own target filled in.
- In a table of repeated phases, each row is a phase with its own number and
  checkboxes; the recipe above the table and the common checks say what those
  checkboxes stand for.
- A check that can only be done in an environment the merge deploys to is
  "after merge", even when the plan lists it under "before merge".
- Sort every check into one of four groups, by what it needs:
  - **Before the pull request:** commands you can run in the working copy
    (build, tests, lint, formatting, a dry run).
  - **On the pull request:** checks that need an open pull request — CI
    results on it, a label or a preview environment it triggers, a reviewer's
    approval. These can be automated or manual.
  - **After merge:** checks in the environment the merge deploys to.
  - **After rollout:** checks after the change is deployed to production.
- When you cannot tell what a part or a check means, ask; do not guess.

## Reconcile the progress

Work done outside this skill — by hand, in another session, or by a merged pull
request — often leaves the plan's checkboxes empty. Before you pick a phase,
compare three sources:

1. **The plan's checkboxes**, in the phase blocks and in the tables.
2. **The card**: its `Outcome` (one line per phase, see "Record the phase") and
   its `prs`.
3. **The pull requests**: for every pull request the card or the plan ties to a
   phase, `gh pr view <pr> --json number,state,mergedAt,headRefName,url`. When
   a phase that changes code has none recorded, look for one:
   `gh pr list --author @me --state all --limit 30` in the plan's repositories,
   matched by branch name and title.

From them, give each phase one state:

| State | Means |
|---|---|
| not started | No branch, no pull request, no checked box, nothing in `Outcome` |
| in progress | A branch or commits for it exist, but no pull request yet |
| in review | Its pull request is open |
| merged | Its pull request is merged, or a phase without code had its actions done; "before merge" checks may still need the user's confirmation |
| done | Merged, with its automated, "before merge", and "after merge" checks confirmed |
| rolled out | Done, and its "after rollout" checks confirmed |

When the sources disagree — `Outcome` or a merged pull request says a phase is
done but its boxes are empty; a box is checked but the pull request was closed
without merging; an open pull request is missing from the card — show the
user a short table (phase, plan, card, pull request) and ask how to fix it
before you change anything. You may tick an automated box yourself only when
you verified it now, such as CI that passed on a merged pull request. Manual
boxes are ticked only after the user confirms them, also in answer to this
question.

## Pick the phase

- If the user named a phase, use that one. When its dependencies are not done,
  say so and ask whether to go ahead anyway.
- Otherwise take the first phase that is **not started** and whose "Depends on"
  phases are done. A dependency that the plan says needs its "after rollout"
  checks counts only once it is rolled out.
- A phase that is **in progress** or **in review** is not started again. When
  one exists, say so and ask whether to continue it or to start the next free
  phase; phases the plan allows in parallel can be worked on side by side.
- When an open question in the plan blocks the phase and has no answer in the
  plan, the card, or the conversation, ask it before you start, and say what
  the phase cannot finish without it.
- Report "after rollout" checks still open on earlier phases in every report
  until the user confirms them.

## Required pre-flight check

Before editing any files, read fully:

- the plan (required, no limit/offset — you need complete context)
- the card and the case's `research*.md`
- the case's `architecture.md` and `data-model.md`, if present

On the first phase, set the card's status to `in-progress`, set `updated`, and
rebuild the index.

## Prepare the branch

A phase that changes code gets its own branch in each repository it touches.
A phase without code changes (closing pull requests, a release, a setting)
needs no branch: do its outward actions, asking before each one.

1. **Find the checkout.** The plan's header names the repositories and the
   branch each one was planned against. Find each one's local checkout: the
   current working directory, or a folder of that name under the folder Claude
   was started in. Ask when you cannot find it.
2. **Check that the user can push there**
   (`gh repo view <owner>/<repo> --json viewerPermission`). With read access
   only, say so before any work, and ask how the change will get in: a fork
   (a new repository under the user's account, an outward action), access from
   the owners, or someone else's pull request.
3. **Check the working copy.** `git status`. When it has uncommitted changes
   that are not this phase's, stop and ask: the user may commit them, move
   them, or prefer a separate worktree (`git worktree add`). Never stash or
   discard them.
4. **Continue, don't restart, a phase in progress.** When the phase already has
   a branch whose pull request is open or not created yet, switch to it, fetch,
   and say how far it is behind the base. Do not rebase, merge the base in, or
   force-push without the user's yes.
5. **Otherwise create a new branch from the fresh base.** The base is the
   branch the plan names for that repository, or else the repository's default
   branch.
   - `git fetch origin <base>`, then `git switch -c <branch> origin/<base>`.
   - Name the branch for the phase, in the style of the user's recent branches
     in that repository (a personal prefix, a ticket, kebab case). The name
     says what the phase does; a phase number alone is not enough.
   - Never reuse a branch name that exists locally or on the remote, and never
     continue on the branch you found checked out when its pull request is
     merged or closed (`gh pr list --head <branch> --state all`).
   - When the user wants this phase stacked on an earlier phase that is not
     merged yet, branch from that phase's branch instead, and say that its pull
     request must be merged first.
6. Tell the user the repository, the base and its commit, and the new branch.

## Implementation process

1. State the phase you are about to implement and why it is next.
2. List the files likely to change.
3. Make the smallest useful change to satisfy that phase. Then read the
   comments in your diff against `../../references/code-comments.md`, and
   remove each one that restates the code or tells the story of the change.
4. Add or update tests.
5. Run the phase's checks that work **before the pull request**. Check off the
   automated `- [x]` items you verified, directly in the plan.
6. Update the plan if the implementation deviated from it, and note anything a
   later reader must know in the card's `Findings` or `Lessons`.
7. **Ask to open the pull request.** Show what is ready, what passed, and which
   checks need the pull request, then ask: "Open the pull request now?" On the
   user's yes, run `/dev-skills:pr <base>` (the base from "Prepare the
   branch"). Pushing and opening the pull request belong to the `pr` skill,
   which follows its own rules. When the user says no, skip to step 9 and list
   the checks that wait for the pull request.
8. **Run the checks that work on the pull request.**
   - Automated ones, such as CI: `gh pr checks <pr>`. Tick the boxes that
     passed. When checks are still running, say so; the next run ticks them.
     Do not wait in a loop.
   - Manual ones: list them for the user. Adding a label, requesting a review,
     or anything else visible on the pull request is an outward action: ask
     first.
9. **Pause for human verification** (see below) — do not start the next phase.

## After the merge

The user merges. On the next run, or when the user says the pull request is
merged, reconcile again: confirm the "before merge" checks with the user and
tick them, and set the phase's `Outcome` line to merged. Run the "after merge"
checks you can run in the environment the merge deployed to, list the ones only
the user can do (a page behind a login, for example), and pause for them. Then
list the phase's "after rollout" checks and outward actions (a release, for
example). Ask before each outward action.

Right after you start a workflow, a deploy, or a release, check that it
started the jobs you expected; a run that fails before its main job applied
nothing.

## Record the phase

The card's `Outcome` keeps one line per phase that has started, in the form
the knowledge-base reference gives. Write the line when the branch is created
(or, for a phase without code, when its actions are done), and update it when
the pull request opens, merges, or the user confirms checks. Add each phase's
pull request to the card's `prs`. Set `updated` and rebuild the index whenever
you change the card.

The card stays `in-progress` until the last phase of the plan: an open or
merged pull request for one phase does not move it to `in-review` or `solved`.
It becomes `in-review` only when the last phase's pull request is open and
every other phase is merged, and `solved` when that pull request is merged.

## Pause for human verification

After the phase's checks have run, stop and report in this shape, then wait.
Write it in the user's language, the labels included, and leave out a line
that would be empty:

```text
Phase N — ready for manual verification.

Branch: <repository> `<branch>` from `<base>` — pull request: <link, or "not opened">
Changed: <the files or areas, one line>
Deviations from the plan: <what and why, or leave out>

Automated checks: <what you ran and the result>
On the pull request: <CI result, or "pending" / "no pull request yet">

Please verify manually before merge:
- <"before merge" items for this phase>

After merge, in <environment>:
- <"after merge" items for this phase>

After rollout, still open:
- <"after rollout" items of this and earlier phases, if any>

Tell me when manual testing passes and the pull request is merged, and I'll
continue with Phase <next>.
```

## Scope control

If you discover that the plan is wrong or incomplete:

- Stop implementation.
- Explain the mismatch clearly:

  ```text
  Issue in Phase N:
  Expected: <what the plan says>
  Found: <actual situation>
  Why it matters: <explanation>

  How should I proceed?
  ```

- Update the plan or recommend running `/dev-skills:architecture` or
  `/dev-skills:data-model`.
- Wait for the user's direction before continuing if the change is significant.

## Definition of done

A run is done only when:

- The phases' states were reconciled, and every disagreement was settled with
  the user.
- The phase was implemented on its own branch from an up-to-date base, or needed
  no branch because it changes no code.
- Its checks before the pull request pass (or their limits are explained), and
  their automated `- [x]` items are checked off in the plan.
- The pull request was opened through `/dev-skills:pr` on the user's yes, or the
  report says it was not.
- The card's `Outcome` has the phase's line, its status follows "Record the
  phase", and the index is current.
- Documentation is not stale.
- The code's comments follow `../../references/code-comments.md`.
- No extra unplanned scope was added.
- You have paused and asked the user to verify before the next phase.
