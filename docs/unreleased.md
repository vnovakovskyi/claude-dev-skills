# Running unreleased changes

The install commands in the README give you the latest **release**, which is
what the `main` branch holds. Everything newer lives on `dev` (the next release)
or on a feature branch. This page is for running that code before it is
released: to get a fix early, to try a pull request, or to test a skill while
you write it.

Two things to know first:

- **Unreleased code can be broken**, and it has no version of its own. The
  version number changes only with a release, so `claude plugin list` keeps
  showing the last one.
- **Only one copy of the marketplace can be registered at a time.** If you
  already installed the released version, remove it before you start:

  ```bash
  claude plugin marketplace remove novakovskyi-dev-skills
  ```

The commands on this page are for a shell. Inside a session, write `/plugin`
in place of `claude plugin`.

## From a clone: follows your working copy

The best fit for contributors and for writing skills.

```bash
git clone https://github.com/vnovakovskyi/claude-dev-skills.git
cd claude-dev-skills
git checkout dev
claude plugin marketplace add "$PWD"
claude plugin install dev-skills@novakovskyi-dev-skills
```

Claude Code now reads the plugin straight from the clone. Whatever is in the
working copy is what runs: the result of a `git pull`, another branch you
switched to, your own uncommitted edits. A change shows up in the next session,
or after `/reload-plugins` in an open one. Nothing has to be reinstalled, and the
version number plays no part.

To try someone's pull request, check out its branch in the clone, for example
with `gh pr checkout <number>`.

## From a branch on GitHub: a snapshot

No clone needed. Name the branch (or a tag) after `#`:

```bash
claude plugin marketplace add vnovakovskyi/claude-dev-skills#dev
claude plugin install dev-skills@novakovskyi-dev-skills
```

This copies the branch as it is at that moment. Later commits do not arrive on
their own, and `claude plugin update` answers "already at the latest version",
because the version number has not changed. To take the newer commits, refresh
the marketplace and install the plugin again:

```bash
claude plugin marketplace update novakovskyi-dev-skills
claude plugin uninstall dev-skills@novakovskyi-dev-skills
claude plugin install dev-skills@novakovskyi-dev-skills
```

## For one session: nothing installed

```bash
claude --plugin-dir /path/to/claude-dev-skills/plugins/dev-skills
```

This loads the plugin from that folder for the one session. It takes the place
of an installed copy with the same name, and your installation stays as it was.

## The optional gate

`phase-gate` works the same way. Install it from the marketplace you registered
above:

```bash
claude plugin install phase-gate@novakovskyi-dev-skills
```

## Back to the released version

Remove the marketplace, add it from GitHub without a branch, and install again:

```bash
claude plugin marketplace remove novakovskyi-dev-skills
claude plugin marketplace add vnovakovskyi/claude-dev-skills
claude plugin install dev-skills@novakovskyi-dev-skills
```

Removing the marketplace uninstalls its plugins and forgets its settings, so if
you use auto-update, turn it on again afterwards.
