# The user's own pull request

Step 1 of the skill sends you here when the pull request's author is the user
(`gh api user --jq .login`). Review it with the same rules and the same rigor:
the description's claims and the tests are checked as if someone else wrote
them. What changes is the outcome:

- No draft comments: in the review file, a finding ends with **Fix:** — the
  concrete change, in the file and lines it touches — in place of **Draft
  comment**. The chat summary says the fix in a few words.
- Nothing is posted, not even a pending review.
- The review ends by asking which findings to fix. Fixing is a separate step,
  done only on the user's word: commit on the pull request's branch through
  `/dev-skills:pr`, which also updates the description when the change makes it
  wrong (counts, claims, how to verify). This skill itself never commits.
