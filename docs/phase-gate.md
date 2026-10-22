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

The gate is **opt-in per folder** via a marker file in the folder you start
Claude in — the same folder whose `docs/` holds the knowledge base:

```bash
touch .claude-phase-gate          # enable the gate for this folder
```

In a folder without the marker, the hook does nothing.

While the gate is active and implementation is **not** approved, Claude may edit
the knowledge base and planning files, but source-code edits are blocked.
Approval is per case. When the plan of the active case looks right, approve it
yourself:

```bash
echo <case slug> > docs/.approved
```

Implementation is approved when all of this holds:

- `docs/.active` names a case;
- that case's folder, `docs/cases/<slug>/`, has a `research*.md` and a
  `plan*.md`;
- `docs/.approved` holds the same slug.

When `/dev-skills:research` moves on to another case, `docs/.active` changes and
the old approval no longer applies, so each case needs its own.

Claude is blocked from writing `docs/.approved` at all times, before and after
approval, through the edit tools and through obvious shell writes.

## Gate behavior

Allowed before approval: `docs/**` (except `docs/.approved`), `CLAUDE.md`,
`.claude/**`, `README.*`.

Blocked before approval: source/config/build/migration file edits, and
file-mutating shell commands. The Bash check is a **soft backstop** (not a full
shell parser):

- Blocks: `rm rmdir mv cp touch mkdir chmod chown ln dd tee truncate`, `sed -i`,
  `perl -pi`, and output redirection into a file (`> file`, `>> file`, etc.).
- Allows: read-only redirections (`2>&1`, `2>/dev/null`) and interpreters/build
  tools (`python`, `node`, `npm`, `make`, …), so research isn't obstructed.

If it ever blocks something harmless, approve the case or temporarily
`rm .claude-phase-gate`.

## Caveat: approval lasts until the case changes

`docs/.approved` stays until you change it, so if you re-plan the same case
after approving, the old approval still applies. Remove it
(`rm docs/.approved`) when you re-plan.

## Version control

Nothing the gate reads lives in a repository's tracked files: `docs/` is the
knowledge base of the folder you start Claude in, kept out of version control as
the skills describe. `.claude-phase-gate` sits in that same folder; when that
folder is a repository, keep the marker personal by listing it in
`.git/info/exclude`, or commit it to share the gate with the team. For anyone
without the plugin installed, the marker is an inert empty file.

## Turn it off

Remove the marker from a project to switch the gate off there, or uninstall the
plugin to remove the hook everywhere:

```text
/plugin uninstall phase-gate@novakovskyi-dev-skills
```
