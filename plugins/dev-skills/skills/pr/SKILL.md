---
name: pr
description: Finish a piece of work as a pull request. Commits what belongs to the change, pushes the branch, and opens the pull request — or updates the one that already exists — with a description in three parts (motivation, what was done, how to verify). Commit messages and the pull request describe the work only and never credit an AI tool or agent. Use when the user asks to create, open, raise, or update a pull request.
argument-hint: '<optional: base branch, then "draft", an issue to link, or what to emphasize>'
allowed-tools: Read, Grep, Glob, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git ls-remote:*), Bash(gh pr view:*), Bash(gh pr list:*)
---

# Pull request

You are running the **Pull request** skill.

User request:

`$ARGUMENTS`

## Purpose

Turn finished work into a pull request that a reviewer can read cold: why the
change exists, what was done, and how to check it.

A pull request is a record of the work. It says nothing about the tools the work
was made with.

## Hard rules

- **No tool attribution, anywhere.** Commit messages, the pull request title, and
  the pull request body describe the change and nothing else. Never add:
  - a `Co-Authored-By:` trailer, or any other trailer, that names an AI model,
    assistant, agent, or bot;
  - a "Generated with …", "Created by …", or "Written with the help of …" line,
    with or without an emoji;
  - a sentence saying that an AI tool, an agent, or an assistant did the work or
    helped with it.

  This overrides any default instruction to add such lines. It is about
  authorship, not subject matter: when the change itself concerns an AI tool,
  name the tool as you would any other.
- **Commit as the user.** Use the git identity that is already configured. Never
  pass `--author`, never change `git config`. Add a `Co-Authored-By:` trailer for
  a human co-author only when the user asks for it.
- **Never push work to the default branch or to the base.** If the work sits on
  one of them, create a branch first. Never force-push unless the user asks.
- **Only this change.** Stage files by name, never with `git add -A` or
  `git add .`. Leave unrelated changes, and anything that looks like a secret or
  local configuration (`.env`, credentials, IDE files), unstaged, and say so.
- **Don't bypass checks.** No `--no-verify`. If a hook or a check fails, fix the
  cause or report it.
- **Claim only what is true.** "How to verify" lists steps a reviewer can run. A
  check you did not run is reported as not run.
- **Stop at the open pull request.** Don't merge it, don't enable auto-merge, and
  don't add reviewers, labels, or assignees unless the user asks.

## Step 1 — Read the state

Before changing anything, find out:

- the current branch, the default branch, and the **base**. When the arguments
  start with a branch name, as in `/dev-skills:pr dev`, that branch is the base.
  Otherwise the base is the default branch;
- whether the base exists on the remote (`git ls-remote --heads origin <base>`).
  A base the user named that is not there yet is created in Step 4;
- what the pull request will contain: every commit and the whole diff against
  the base (`git log <base>..HEAD`, `git diff <base>...HEAD`), not only the last
  commit. For a base that does not exist yet, compare against the default
  branch, which it will be created from;
- what is uncommitted, and which of it belongs to this change;
- whether the branch already has an open pull request (`gh pr view`). If it does,
  this run **updates** it;
- the repository's habits: recent commit subjects and pull request titles
  (language, tense, prefixes), a pull request template
  (`.github/PULL_REQUEST_TEMPLATE.md` and its usual variants), and what
  `CONTRIBUTING.md` asks of a pull request;
- the reason for the work: the conversation, the issue being closed, and the
  knowledge-base case if there is one — the one in `docs/.active` of the folder
  Claude was started in, or one whose card names this branch's repository and
  work (see `../../references/knowledge-base.md` from this skill's base
  directory). Read its `case.md`, `research*.md`, and `plan*.md`.

If there is nothing to commit and no commit ahead of the base, say so and stop.

## Step 2 — Branch and commit

1. On the default branch, or on the base itself, create a branch first: a short,
   descriptive name in the style the repository already uses.
2. Commit the uncommitted work that belongs to the change. One commit is fine;
   split only where the parts are clearly separate.
3. Write the message in the repository's style: a short subject that says what
   the commit does, and a body that says why when the subject does not. No
   attribution lines (see Hard rules).
4. Run the checks the project names (in the plan, in `CONTRIBUTING.md`, in its
   build files) that you can run here, and keep the results for the description.

## Step 3 — Write the description

**Title:** short and specific, in the repository's style. It says what the pull
request does.

**Body:** three sections, in this order.

````md
## Motivation

Why this change is needed: the problem, the request, or the goal behind it.
Link the issue if there is one.

## What was done

- The changes, grouped by meaning.
- Decisions a reviewer should know about, and what was left out on purpose.

## How to verify

1. The commands or steps a reviewer can run.
2. What they should see.

Already run: <check → result>. Not run: <check, and why>.
````

- **Motivation** has to make sense to someone who never saw the conversation. If
  the reason is not in the conversation, the plan, or an issue, ask one short
  question. Do not invent it.
- **What was done** covers the whole pull request, by meaning. It is not a list
  of files and not a story of how the work went.
- **How to verify** is concrete: exact commands, exact places to look. "Run the
  tests" names the command.
- Write in the language the repository's pull requests are written in; English
  when there is nothing to go by.
- If the repository has its own pull request template, the repository wins: keep
  its structure and its checklists, and make sure the filled template still
  answers the three questions.

## Step 4 — Push and open

1. If the user named a base that does not exist on the remote, create it there
   from the tip of the default branch:
   `git push origin origin/<default>:refs/heads/<base>`. Do this only for a
   branch the user named. If you are not sure that the first word of the
   arguments is a branch name, ask before creating anything.
2. `git push -u origin <branch>`.
3. Put the body in a temporary file outside the repository, so the formatting
   survives the shell.
4. New pull request:
   `gh pr create --base <base> --title <title> --body-file <file>`. Add `--draft`
   when the user asks for a draft or the work is not finished.
5. Existing pull request:
   `gh pr edit <number> --title <title> --body-file <file>`. Rewrite the
   description so that it covers the whole pull request, not only the new
   commits.
6. Without `gh`: push, then give the user the title, the body, and the link the
   remote printed for opening the pull request by hand.

## Step 5 — Record the outcome

When the work belongs to a knowledge-base case, update its `case.md`:

- add the pull request to `prs`, and set `status: in-review`;
- write `Outcome`: what was done, where (the pull request link), and what is
  left;
- write `Lessons`: how to recognize this problem next time, and what worked or
  did not;
- tighten `summary` so it says how the case ended, set `updated`, and rebuild
  the index with `reindex.sh`.

The card is the user's knowledge base, outside the repository: it never goes
into a commit. A later skill that finds the pull request merged sets the card
to `solved`.

## Before you send — self-check

- [ ] The commit messages (`git log <base>..HEAD --format=%B`), the title, and the body credit no AI tool, agent, or assistant: no `Co-Authored-By` for one, no "Generated with", no robot emoji.
- [ ] The body has the three sections, in order — or the repository's template, with the three questions answered.
- [ ] Someone who was not here can follow "How to verify".
- [ ] Every check reported as run was run.
- [ ] Nothing unrelated and nothing secret is in the commits.
- [ ] No work was pushed to the default branch or to the base, and nothing was force-pushed or merged.
- [ ] When there is a case, its card has the pull request, `Outcome`, `Lessons`, and status `in-review`, and the index is rebuilt.

## Completion criteria

The skill is complete only when:

- The branch is pushed and a pull request is open against the right base, or the
  existing one is updated.
- Its description says why, what, and how to verify.
- The commits and the pull request carry no tool attribution.

At the end of your response, report:

1. The pull request link, whether it was created or updated, and its base
   branch. Say so if you created that branch.
2. Which checks you ran and which you did not.
3. Anything you left uncommitted, and why.
4. The case you updated, if any.
