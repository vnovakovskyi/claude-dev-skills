# Subagent brief

Use this brief for each area of a large pull request that you hand to a
subagent. Fill in every placeholder. A subagent sees nothing but the brief: not
the skill, not the conversation, not the other subagents.

```md
Read-only review of part of a pull request. Do not post anything to the pull
request or anywhere else. Do not check out, commit, push, stash, or reset in the
repository; read the code with `git show <head sha>:<path>`. Do not run
installs, generators, migrations, or builds.

Pull request: <link> — <what it is meant to do, in two lines>
Head commit: <sha>   Merge base: <sha>   Repository: <local path>

Your area: <files, service, or layer this subagent reviews>
Do not cover: <the areas other subagents own — name them>

Already known (do not re-report):
- <points already raised on the pull request, and facts established so far>

Look for: wrong results on edge cases, ordering and transaction gaps, unsafe
retries, broken callers or consumers of anything changed (search the whole
repository for them), data and migration risks, security gaps, and claims of the
description that the code does not keep. Skip formatting and naming.

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
