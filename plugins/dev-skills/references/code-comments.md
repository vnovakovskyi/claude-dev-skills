# Comments in code

Every dev-skills skill that writes or suggests code follows this. Skills reach
this file as `../../references/code-comments.md` from their own base directory.

## The rule

Code explains itself. A reader understands what it does and how from names,
types, small functions, and tests, not from comments. A comment is the
exception: write one only for what the code cannot say.

Comments go stale. No compiler or test checks them, so they drift from the code
they describe, and a stale comment misleads the next reader. Every comment you
write is one more thing to keep true.

Before you write a comment, try to make it unnecessary: a clearer name, an
extracted method or constant, a more precise type, a test that pins the
behavior. Write the comment only when that cannot carry the meaning.

## When a comment is right

- **Why, when the obvious way is wrong.** A constraint the code alone does not
  show: a permission the service lacks, a library bug worked around, a security
  or performance reason. For example: "The request URI is not used here: this
  runs before authentication, so any caller could add tag values."
- **A contract a caller must know** and cannot see from the signature: a
  thread-safety rule, an ordering requirement, a unit.

Keep it to one or two lines. A comment that needs a paragraph is usually an
explanation for the commit message, the pull request, or the documentation.

## Never write

- A comment that restates the code: `// increment the counter`,
  `// returns the user`, `// call the service`.
- The story of the change: `// changed to HeadBucket`, `// new in Boot 4`,
  `// fixed the bug with X`. The commit message and the pull request hold that.
- References to tickets or issues: `// see ABC-123`, `// per FS-1324`. The
  ticket belongs in the commit message; in the code it goes stale as soon as the
  ticket is closed or the code moves on.
- Doc comments (Javadoc, KDoc, JSDoc, docstrings) on members whose name and
  signature already say everything.
- A comment in a test that repeats the test's name or its assertions.
- Commented-out code, section banners, and TODOs.

## Existing code and the repository's rules

- Do not delete or rewrite comments in code your change does not touch.
- When your change makes a comment wrong, fix the comment or remove it.
- The repository's own rules come first: when it requires doc comments on a
  public API, license headers, or annotations in comments, write them.
