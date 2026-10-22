# Subagent brief

Use this brief for each sub-question you hand to a subagent. Fill in every
placeholder. A subagent sees nothing but the brief: not the skill, not the
conversation, not the other subagents.

```md
Read-only research. Do not change files, run installs, generators, migrations,
formatters, or build tools that refresh a cache (nx graph, mvn, gradle).
Reading, searching, git log/blame/show/diff, and read-only gh calls are fine.

Question: <the sub-question, in one sentence>

Where to look: <repositories and directories this subagent owns>
Do not cover: <the areas other subagents own — name them, so they are skipped>

Already established (do not re-derive):
- <fact> — <path:line>

Rules:
- Describe the code as it is. Do not suggest improvements or designs. Where the
  code contradicts itself, report both sides with sources under
  "Inconsistencies", without a recommendation.
- Every claim has a file and line. Give paths from the repository root and name
  the repository.
- Mark each claim OBSERVED (you read the line) or INFERRED (you reasoned it from
  something else, and say from what).
- For every count (files, imports, usages), give the command that produced it,
  so it can be re-run.
- Report only what answers the question. Keep the report under about 150 lines:
  a few examples per pattern, not every hit.

Report in this shape, nothing else:

## Claims
- <claim> — <repo>/<path:line> — OBSERVED | INFERRED (<from what>)

## Counts
- <what was counted>: <number> — `<command>`

## Inconsistencies
- <side A> — <path:line>; <side B> — <path:line>

## Not found
- <what you looked for and where, and did not find>
```

Keep the "Do not cover" list concrete. Two subagents that both read the same
proxy configuration, or the same shared library, cost twice and report the same
thing.
