# Subagent brief

Step 5 of the skill sends you here for a large pull request: many services, or
many hundreds of changed lines of logic (fixtures, snapshots, generated code,
and lockfiles do not count). Split it into 2–4 areas that do not overlap, by
service or layer, and tell the user in one line how you split it. While
subagents run, do not review their areas yourself. Step 6 stays with you.

Use this brief for each area. Fill in every placeholder. A subagent sees nothing
but the brief: not the skill, not the conversation, not the other subagents.

```md
Read-only review of part of a pull request. Do not post anything to the pull
request or anywhere else. Do not check out, commit, push, stash, or reset in the
repository; read the code with `git show <head sha>:<path>`. Do not run
installs, generators, migrations, or builds. Do not query running systems.

Pull request: <link> — <what it is meant to do, in two lines>
Head commit: <sha>   Merge base: <sha>   Repository: <local path>

How the change works: <from Step 4 — what the result depends on, where it comes
from, every path that reaches the changed code, the life of the data>
Checklist for this kind of change: <the matching list from
references/checklists.md, pasted in full, or "none">
Numbers that need a running system: report them as a question, with what would
settle them; do not estimate them into a finding.

Your area: <files, service, or layer this subagent reviews>
Do not cover: <the areas other subagents own — name them>

Already known (do not re-report):
- <points already raised on the pull request, and facts established so far>

Look for: wrong results on edge cases, ordering and transaction gaps, unsafe
retries, broken callers or consumers of anything changed (search the whole
repository for them), data and migration risks, security gaps, and claims of the
description that the code does not keep. Skip formatting and naming.

For tests in your area, say which requirement each one proves, and report
signs of a test bent to pass: assertions that always hold, a mock that returns
what the test then asserts or returns null, skipped tests, raised timeouts or
retries, a test that bypasses the part it claims to check, and expected values
changed without a changed requirement. Do not run the tests.

Rules:
- Report only problems the pull request adds or makes worse. Put problems that
  were there before under "Outside".
- Every finding has a file and line at the head commit and a concrete case:
  input or sequence → wrong result.
- Mark each finding OBSERVED (you traced it in the code) or INFERRED (say which
  step you could not see).
- Keep the report under about 120 lines.

Report in this shape, nothing else:

## Findings
- <title> — <path:line> — <case → wrong result> — OBSERVED | INFERRED (<why>)

## Checked and fine
- <what you checked> — <path:line>

## Outside
- <problem that predates the pull request> — <path:line>
```
