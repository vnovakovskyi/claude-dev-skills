# Post what the user chose

Read this only after the user has told you, in their own message, which
findings to post. It never applies to the user's own pull request: nothing is
posted there.

Only with the wording the user approved:

1. Show the final text of every comment once more when the user changed
   anything, and wait for their yes.
2. Check that the user has no pending review on this pull request already
   (`gh api repos/<owner>/<repo>/pulls/<n>/reviews` and look for `PENDING`).
   GitHub allows one; if there is one, stop and tell the user.
3. Check the head again (`gh pr view <n> --json headRefOid`). When it moved
   since the review, re-check the chosen findings and their lines at the new
   head first, and tell the user what changed.
4. Create one pending review on the head commit. Leave out `event`, so the
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
5. Give the user the pull request link and tell them the review is pending:
   they open "Files changed", read it there, and submit it with the verdict they
   choose. You never submit it.
