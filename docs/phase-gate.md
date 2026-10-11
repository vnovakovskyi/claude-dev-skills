# The optional hard gate

By default the workflow is soft: the skills tell Claude to stop and wait, and
Claude follows. If you want Claude to be *physically* unable to edit code before
you approve, install the second plugin:

```text
/plugin install phase-gate@novakovskyi-dev-skills
```

`phase-gate` adds one `PreToolUse` [hook](https://code.claude.com/docs/en/hooks)
(matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`) that runs
`scripts/gate.sh` before every file edit and shell command. The hook comes with
the plugin, so there is nothing to add to `settings.json` by hand, and
uninstalling the plugin removes it.

The hook needs `bash` and `jq`. If `jq` is missing, the hook fails open: it
allows everything and enforces nothing. On macOS: `brew install jq`.

## Turn it on for a project

The gate is **opt-in per project** via a marker file. In a project's root:

```bash
touch .claude-phase-gate          # enable the gate for this project
```

In a project without the marker, the hook does nothing.

While the gate is active and implementation is **not** approved, Claude may edit
docs/planning files but source-code edits are blocked. To approve:

```bash
touch .claude-phase-approved      # approve implementation (run this yourself)
```

Approval requires `docs/00-research.md` and `docs/01-plan.md` to exist plus the
`.claude-phase-approved` file. Do **not** let Claude create `.claude-phase-approved`
itself — that would defeat the gate (the gate blocks Claude from creating it).

## Gate behavior

Allowed before approval: `docs/**`, `CLAUDE.md`, `.claude/**`, `README.*`.

Blocked before approval: source/config/build/migration file edits, and
file-mutating shell commands. The Bash check is a **soft backstop** (not a full
shell parser):

- Blocks: `rm rmdir mv cp touch mkdir chmod chown ln dd tee truncate`, `sed -i`,
  `perl -pi`, and output redirection into a file (`> file`, `>> file`, etc.).
- Allows: read-only redirections (`2>&1`, `2>/dev/null`) and interpreters/build
  tools (`python`, `node`, `npm`, `make`, …), so research isn't obstructed.

If it ever blocks something harmless, approve implementation or temporarily
`rm .claude-phase-gate`.

## Caveat: approval is a persistent flag

`.claude-phase-approved` stays until you remove it, so if you re-run
`/dev-skills:plan` after approving, the *old* approval is still in effect. With
the gate, remove the file (`rm .claude-phase-approved`) when you re-plan. The
soft (default) workflow avoids this entirely because it has no approval file.

## Version control of the marker files

The marker files live in each working project, so committing them is a
per-project decision (made in that project's `.gitignore`):

- **`.claude-phase-approved` — recommended to gitignore.** It is transient, local,
  per-developer state. If committed, every clone is permanently "approved".
- **`.claude-phase-gate` — your choice:** commit it to share the gate with the
  team, or gitignore it to keep the gate personal. For anyone without the plugin
  installed, the marker is an inert empty file and changes nothing.

Suggested per-project `.gitignore`:

```gitignore
# Local implementation approval — never commit (would disable the gate on clone)
.claude-phase-approved

# Phase-gate opt-in: uncomment to keep it personal/local instead of shared.
# .claude-phase-gate
```

## Turn it off

Remove the marker from a project to switch the gate off there, or uninstall the
plugin to remove the hook everywhere:

```text
/plugin uninstall phase-gate@novakovskyi-dev-skills
```
