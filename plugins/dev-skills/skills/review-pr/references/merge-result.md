# Run the tests on the merge result

Step 2 of the skill sends you here when the base branch changed the modules the
pull request's tests cover since the merge base. The pull request will be
merged into the base as it is now, so run the tests on the merge result,
without a commit, in a temporary worktree outside the repository:

```bash
git -C <repo> worktree add --detach <tmp> origin/<base>
git -C <tmp> merge --no-commit --no-ff <head sha>
# run the tests in <tmp>
git -C <tmp> merge --abort
git -C <repo> worktree remove --force <tmp>
```

When several checks need a build each (the tests at the head, the merge result,
the mutations of Step 6), give each its own worktree and run them in the
background at the same time instead of one after another. Remove every
worktree afterwards.
