# Contributing to Claude Dev Skills

Thanks for your interest in improving this project! It's a small, personal
collection of reusable [Claude Code](https://code.claude.com) skills for
software development (and an optional enforcement hook) that anyone is welcome
to use and improve.

**Every change comes in through a pull request** against `main`. That is the
only way a contribution gets merged.

Contributions are reviewed personally by the maintainer. Not every change will
be merged, and response times may vary — but well-scoped, tested PRs are always
appreciated.

## Project scope

This repo is intentionally **generic and reusable across projects**. Good
contributions keep it that way.

**In scope:**

- New or improved general-purpose development skills (`skills/<name>/SKILL.md`).
- Improvements to the optional phase-gate hook (`hooks/gate.sh`).
- The install/uninstall tooling (`install.sh`, `uninstall.sh`).
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
5. Open a **Pull Request against `main`**. Describe the *motivation*, *what was
   done*, and *how to verify* it — the pull request template has these three
   sections.
6. The maintainer reviews, may ask for changes, and merges when it's ready.

**Issues:** direct PRs are welcome for small fixes. For large, breaking, or
design-level changes, please **open an issue first** so we can agree on the
approach before you invest time.

## Testing your change

There's no heavy test framework — keep it simple and verify locally before
submitting:

- **Shell scripts:** syntax-check anything you touched.

  ```bash
  bash -n install.sh uninstall.sh hooks/gate.sh
  ```

- **Install / uninstall:** run them against a throwaway `HOME` so you never
  touch your real `~/.claude`:

  ```bash
  export HOME=/tmp/cds-test && rm -rf "$HOME" && mkdir -p "$HOME/.claude"
  ./install.sh                # default (skills only)
  ./install.sh --with-gate    # also registers the optional hook
  ./uninstall.sh              # should cleanly reverse both
  ```

  Confirm symlinks land in `~/.claude/skills/`, that `--with-gate` adds the
  `PreToolUse` entry to `settings.json` (and backs it up), and that uninstall
  removes only what it added.

- **Phase-gate hook (`hooks/gate.sh`):** if you change its logic, exercise both
  the "should allow" and "should block" cases. Feed it sample JSON payloads from
  a directory that contains a `.claude-phase-gate` file (without the marker the
  gate allows everything):

  ```bash
  echo '{"cwd":".","tool_name":"Bash","tool_input":{"command":"npm test 2>&1"}}' | bash hooks/gate.sh; echo "exit=$?"
  ```

  Read-only commands (`2>&1`, `/dev/null`, interpreters) should pass; file-writing
  commands and source edits (without approval) should exit `2`.

- **Skills:** run the changed skill in a real project and read what it writes
  to `docs/`. Say in the PR what you ran it on.

- **`shellcheck`** is recommended if you have it installed.

## Conventions

- **Skills** live in `skills/<name>/SKILL.md` with YAML frontmatter:
  - `name`, `description` (used for discovery), `argument-hint`, and
    `disable-model-invocation: true` for the manual workflow phases.
  - Keep the "research → plan → implement" philosophy: skills should avoid
    jumping to implementation early, and the workflow stays **soft** by default
    (phased plans + human pauses), with the hook as optional hard enforcement.
- **Docs numbering** (`docs/00`–`03`) indicates document *type*, not order.
- **Markdown:** plain GitHub-flavored Markdown, English, wrap reasonably.
- **Update the README** when you change user-visible behavior.

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
