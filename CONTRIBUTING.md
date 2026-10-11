# Contributing to Claude Dev Skills

Thanks for your interest in improving this project! It's a small, personal
collection of reusable [Claude Code](https://code.claude.com) skills for
software development (and an optional enforcement hook), packaged as plugins
that anyone is welcome to use and improve.

**Every change comes in through a pull request** against `main`. That is the
only way a contribution gets merged.

Contributions are reviewed personally by the maintainer. Not every change will
be merged, and response times may vary — but well-scoped, tested PRs are always
appreciated.

## Project scope

This repo is intentionally **generic and reusable across projects**. Good
contributions keep it that way.

**In scope:**

- New or improved general-purpose development skills
  (`plugins/dev-skills/skills/<name>/SKILL.md`).
- Improvements to the optional phase gate (`plugins/phase-gate/`).
- The plugin and marketplace manifests.
- Documentation, examples, and clarity fixes.

**Out of scope:**

- Skills for writing and editing articles — those live in
  [claude-writer-skills](https://github.com/vnovakovskyi/claude-writer-skills).
- Project-, company-, or stack-specific logic (keep that in your own repo).
- Anything that hard-codes a particular language, framework, or toolchain into
  the core workflow.
- Large new subsystems without prior discussion (open an issue first).

## How to contribute

1. **Fork** the repository and clone your fork.
2. Create a **feature branch** off `main` (e.g. `git checkout -b improve-gate-regex`).
3. Make a **small, focused change** — one logical improvement per PR is much
   easier to review than a large mixed one.
4. **Test** your change (see below).
5. Add a line under **Unreleased** in [CHANGELOG.md](CHANGELOG.md) when the
   change is visible to users.
6. Open a **Pull Request against `main`**. Describe the *motivation*, *what was
   done*, and *how to verify* it — the pull request template has these three
   sections.
7. The maintainer reviews, may ask for changes, and merges when it's ready.

**Issues:** direct PRs are welcome for small fixes. For large, breaking, or
design-level changes, please **open an issue first** so we can agree on the
approach before you invest time.

## Testing your change

There's no heavy test framework — keep it simple and verify locally before
submitting:

- **Manifests and skills:** run the validator from the repository root. It checks
  the marketplace and both plugins.

  ```bash
  claude plugin validate . --strict
  ```

- **Skills:** load your working copy for one session, without installing it, and
  run the changed skill in a real project. Say in the PR what you ran it on.

  ```bash
  claude --plugin-dir /path/to/claude-dev-skills/plugins/dev-skills
  ```

- **Phase gate (`plugins/phase-gate/scripts/gate.sh`):** syntax-check it, and if
  you change its logic, exercise both the "should allow" and "should block"
  cases. Feed it sample JSON payloads whose `cwd` is a directory that contains a
  `.claude-phase-gate` file (without the marker the gate allows everything):

  ```bash
  bash -n plugins/phase-gate/scripts/gate.sh
  G="$(mktemp -d)" && touch "$G/.claude-phase-gate"
  echo "{\"cwd\":\"$G\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"npm test 2>&1\"}}" | bash plugins/phase-gate/scripts/gate.sh; echo "exit=$?"
  ```

  Read-only commands (`2>&1`, `/dev/null`, interpreters) should pass; file-writing
  commands and source edits (without approval) should exit `2`.

- **`shellcheck`** is recommended if you have it installed.

## Conventions

- **Skills** live in `plugins/dev-skills/skills/<name>/SKILL.md` with YAML
  frontmatter:
  - `name`, `description` (used for discovery), `argument-hint`, and
    `disable-model-invocation: true` for the manual workflow phases.
  - The frontmatter must be valid YAML: quote a value that contains `: `.
  - When a skill names another skill's command, it uses the full form:
    `/dev-skills:plan`, not `/plan`.
  - Keep the "research → plan → implement" philosophy: skills should avoid
    jumping to implementation early, and the workflow stays **soft** by default
    (phased plans + human pauses), with the gate as optional hard enforcement.
- **The gate stays opt-in twice:** it is a separate plugin, and it does nothing
  in a project without the `.claude-phase-gate` marker.
- **Docs numbering** (`docs/00`–`03`) indicates document *type*, not order.
- **Markdown:** plain GitHub-flavored Markdown, English, wrap reasonably.
- **Update the README** when you change user-visible behavior.

## Versions and releases

Both plugins share one version number, kept in
`plugins/dev-skills/.claude-plugin/plugin.json` and
`plugins/phase-gate/.claude-plugin/plugin.json`. Users stay on the version they
installed until that number changes, so a change reaches them only with a
release.

Contributors don't bump the version. Add your line under **Unreleased** in
`CHANGELOG.md` and leave the manifests alone.

A release is a pull request by the maintainer that:

1. sets the new version in both `plugin.json` files;
2. renames **Unreleased** in `CHANGELOG.md` to the version and date, and opens a
   new empty **Unreleased**.

After it is merged, the maintainer tags the commit `vX.Y.Z` and publishes a
GitHub release with that changelog entry.

## Commits & pull requests

- Write clear, present-tense commit messages explaining the *why*.
- Keep PRs focused; split unrelated changes into separate PRs.
- A [DCO](https://developercertificate.org/) sign-off (`git commit -s`) is
  welcome but not required.
- By contributing, you agree your contribution is licensed under the project's
  [MIT License](LICENSE) (inbound = outbound).

## License

This project is licensed under the [MIT License](LICENSE). Contributions are
accepted under the same license.
