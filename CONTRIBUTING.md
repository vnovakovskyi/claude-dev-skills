# Contributing to Claude Dev Skills

Thanks for your interest in improving this project! It's a small, personal
collection of reusable [Claude Code](https://code.claude.com) skills for
software development (and an optional enforcement hook), packaged as plugins
that anyone is welcome to use and improve.

**Every change comes in through a pull request against the `dev` branch.**
`main` holds released versions only; see [Branches and releases](#branches-and-releases).

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
2. Create a **feature branch** off `dev`
   (e.g. `git checkout -b improve-gate-regex origin/dev`).
3. Make a **small, focused change** — one logical improvement per PR is much
   easier to review than a large mixed one.
4. **Test** your change (see below).
5. Add a line under **Unreleased** in [CHANGELOG.md](CHANGELOG.md) when the
   change is visible to users. Leave the version numbers alone.
6. Open a **Pull Request against `dev`**. Describe the *motivation*, *what was
   done*, and *how to verify* it — the pull request template has these three
   sections. With the plugin installed, `/dev-skills:pr dev` does this for you.
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

- **Skills:** run the changed skill from your working copy in a real project,
  and say in the PR what you ran it on. [docs/unreleased.md](docs/unreleased.md)
  shows how to make Claude Code read the plugins straight from your clone, or
  load them for a single session:

  ```bash
  claude --plugin-dir /path/to/claude-dev-skills/plugins/dev-skills
  ```

- **Phase gate (`plugins/phase-gate/scripts/gate.sh`):** syntax-check it, and if
  you change its logic, exercise both the "should allow" and "should block"
  cases. Feed it sample JSON payloads whose `cwd` is a directory that contains a
  `.claude-phase-gate` file (without the marker the gate allows everything). Give
  file paths as absolute paths, the way Claude Code sends them:

  ```bash
  bash -n plugins/phase-gate/scripts/gate.sh
  G="$(mktemp -d)" && touch "$G/.claude-phase-gate"
  echo "{\"cwd\":\"$G\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"npm test 2>&1\"}}" | bash plugins/phase-gate/scripts/gate.sh; echo "exit=$?"
  echo "{\"cwd\":\"$G\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$G/docs/cases/c1/plan.md\"}}" | bash plugins/phase-gate/scripts/gate.sh; echo "exit=$?"
  echo "{\"cwd\":\"$G\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$G/src/App.java\"}}" | bash plugins/phase-gate/scripts/gate.sh; echo "exit=$?"
  echo "{\"cwd\":\"$G\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$G/docs/.approved\"}}" | bash plugins/phase-gate/scripts/gate.sh; echo "exit=$?"
  ```

  The first two print `exit=0` and the last two `exit=2`: read-only commands
  (`2>&1`, `/dev/null`, interpreters) and edits under `docs/` pass, while
  file-writing commands and source edits are blocked until approval, and
  `docs/.approved` is blocked always. To check the approved path, create
  `docs/.active` and `docs/.approved` holding `c1`, plus
  `docs/cases/c1/research.md` and `docs/cases/c1/plan.md`, and the source edit
  passes.

- **Knowledge-base index (`plugins/dev-skills/scripts/reindex.sh`):** run it on
  a scratch `docs/` with a few `cases/*/case.md` cards, including one without
  frontmatter, and check `INDEX.md` and the warnings.

- **Review excerpts (`plugins/dev-skills/skills/review-pr/scripts/excerpt.sh`):**
  run it on a pull request in any local clone, on a range of added lines and on a
  range outside the diff, and check the `+` marks, the line numbers, and the
  `inline:` line on stderr.

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
- **The knowledge base format** lives in one place,
  `plugins/dev-skills/references/knowledge-base.md`. Skills point to it instead
  of restating it; change the format there, and in `scripts/reindex.sh` when it
  touches the frontmatter.
- **Markdown:** plain GitHub-flavored Markdown, English, wrap reasonably.
- **Keep the README short.** It says what the project is, how to install it, and
  how to stay up to date. Details go in `docs/`.

## Branches and releases

| Branch | What it holds |
|---|---|
| `main` | Released versions. This is what people install. It changes only when a release is merged. |
| `dev` | The next release, collected one pull request at a time. |

The split exists because of how plugin versions work. Someone who installs a
plugin keeps those files until its version number changes, while a new install
always takes the current `main`. If `main` changed between releases, two people
on the same version would have different skills. So `main` never changes without
a new version number.

Both plugins share one version number, kept in
`plugins/dev-skills/.claude-plugin/plugin.json` and
`plugins/phase-gate/.claude-plugin/plugin.json`. It follows
[semantic versioning](https://semver.org); `CHANGELOG.md` says what counts as
major, minor, and patch here.

A release is made by the maintainer:

1. On `dev`, set the new version in both `plugin.json` files, rename
   **Unreleased** in `CHANGELOG.md` to the version and date, and open a new empty
   **Unreleased**.
2. Open a pull request from `dev` into `main`, titled `Release X.Y.Z`.
3. Merge it **with a merge commit, not a squash**. The two branches then keep a
   shared history, and the next release pull request shows only what is new.
4. Tag the merge commit `vX.Y.Z` and publish a GitHub release with that changelog
   entry. People who watch the repository's releases are notified.

## Repository layout

```text
.claude-plugin/marketplace.json     the marketplace: lists the two plugins
plugins/dev-skills/                 the plugin with the nine skills
  .claude-plugin/plugin.json
  skills/<name>/SKILL.md
plugins/phase-gate/                 the plugin with the optional hard gate
  .claude-plugin/plugin.json
  hooks/hooks.json
  scripts/gate.sh
docs/                               user documentation beyond the README
CHANGELOG.md                        what changed in each version
```

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
