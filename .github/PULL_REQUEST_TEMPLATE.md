<!--
Thanks for contributing! Please keep PRs small and focused.
See CONTRIBUTING.md for scope and the full testing guidance.
-->

## Summary

What does this PR change, and why?

## Linked issue

Closes #<!-- issue number, if any -->

## Type of change

- [ ] Bug fix
- [ ] New skill / hook / enhancement
- [ ] Documentation
- [ ] Other (describe):

## Scope

- [ ] This change is generic and reusable (in scope per [CONTRIBUTING.md](https://github.com/vnovakovskyi/claude-dev-skills/blob/main/CONTRIBUTING.md) — not project-specific logic).

## Testing

- [ ] `bash -n` passes on any changed shell script (`install.sh`, `uninstall.sh`, `hooks/gate.sh`).
- [ ] Ran install/uninstall against a throwaway `HOME` (and `./install.sh --with-gate` if the hook is touched).
- [ ] Exercised `hooks/gate.sh` allow/block cases (only if the gate logic changed).
- [ ] Ran the changed skill in a real project (only if a skill changed).
- [ ] `shellcheck` clean, if available (optional).
- [ ] Updated `README.md` if user-visible behavior changed.

## Notes for the reviewer

Anything else the maintainer should know.
