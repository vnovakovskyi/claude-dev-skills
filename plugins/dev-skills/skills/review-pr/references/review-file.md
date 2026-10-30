# The review file

Step 8 of the skill sends you here to write the review file. It is in the
knowledge base's language (`../../../references/knowledge-base.md`), and draft
comments are in the pull request's language.

The review file holds the whole review in this shape:

```md
**Pull request:** <link> — <title>, by <author>. Reviewed at `<short sha>` (merge base `<short sha>`).

**What it does:** 2–3 lines.

**How it works:** 3–6 lines from Step 4: what the result depends on, where it comes from, which paths reach the changed code, and the life of the data.

**CI:** what passed, what was skipped, what you ran yourself. The base branch: commits since the merge base that touch the same code, and whether it merges cleanly.

**Already on the pull request:** who reviewed and what they raised, in one line each.

**Verdict:** one line — mergeable as is, after the blocking findings, or needs rework.

### Findings

#### 1. <Severity> · <short title> — CONFIRMED | PLAUSIBLE
**[path/to/file.ext, lines 40–42](<link to the lines at the head commit>)** · inline: yes | no

```diff
     37 │         unchanged context line
+    40 │         line the pull request added or changed
     42 │         unchanged line the finding is also about
```

- **Problem:** what is wrong, in one or two sentences.
- **When it goes wrong:** the concrete input or sequence, and the wrong result.
- **Evidence:** the lines and the trace that show it.
- **Suggestion:** the smallest change that fixes it; options when there are several.
- **Already raised:** by whom, and whether you agree — or "no".
- **Draft comment:** (on the user's own pull request: **Fix:** — the change to make)
  > The text to post, in the user's voice and the pull request's language.

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
- What you looked at and found correct, one line each.

**Prior work:** cases from the knowledge base, or "none found".
```

Print the code of every finding with `scripts/excerpt.sh`, run as Step 8 of
the skill shows.

It marks the lines the pull request added or changed with `+` and prints on
stderr whether the range sits inside the diff (`inline: yes`) — only then can
it carry an inline comment. A range that mixes changed and unchanged lines can
come out `inline: no`; narrow it to the changed lines to get an anchor. Pick the
range a comment would be attached to: the line where the problem is and the
lines the reader needs to see it. Give a second place a finding rests on (the
transaction boundary, the consumer) an excerpt of its own under **Evidence**. A
finding about something that is not code (commits, the description) has no
excerpt; say where it is instead. Link sources to the head commit on the host
(`https://github.com/<owner>/<repo>/blob/<head sha>/<path>#L42`), and name the
repository for a file in another one.
