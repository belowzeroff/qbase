# Contributing to qbase

Thanks for your interest in improving qbase! This guide covers how to get set up,
the conventions we follow, and how to submit changes.

## Getting started

- Requires kdb+ **>= 4.0** (verified on 4.1) with `q` on your `PATH`.
- Clone the repository and boot it: `q boot.q`
- Run the test suite: `tests/run.sh` (or `q boot.q < tests/run.q`)

## Project layout

- `src/` — the libraries (one namespace per file: `src/foo.q` → `.foo`)
- `tests/` — the `.test` framework and `test_*.q` suites
- `examples/` — runnable example applications
- `docs/` — MkDocs documentation sources
- `boot.q` — process bootstrap

## Coding conventions

- **Namespaces** — a library `foo` lives in `src/foo.q`, defines the `.foo` namespace,
  and may define `.foo.init` (run once on load). Internal helpers go under `.foo.i.*`.
- **Dependencies** — declare them at the top of the file with
  `` .require.lib each `a`b`c; ``.
- **qdoc** — annotate public functions with `@param`, `@returns` and `@throws`
  comments (see existing files).
- **License header** — every `.q` file starts with a title line and the Apache-2.0
  header.
- **Style** — match the surrounding code: spaces (not tabs), and the comment style
  already used in the file you're editing.

## Adding a library

1. Create `src/mylib.q` with the header, `.require.lib` dependencies, and your
   `.mylib.*` functions (plus an optional `.mylib.init`).
2. Add `tests/test_mylib.q` with `.t.mylib_*` niladic test cases.
3. Run `tests/run.sh` — the suite must stay green.
4. Document it in the README module table (and in `docs/` if it's a core module).

## Tests

Test cases are niladic functions in the `.t` namespace, discovered automatically.
Assertions available: `.test.assert.equals`, `.true`, `.false`, `.notEquals`,
`.raises`, `.raisesLike`. The runner exits non-zero on any failure, which gates CI.

## Commits & pull requests

- Use [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `ci:`, `chore:`, ...).
- Keep pull requests focused and include tests for behaviour changes.
- CI (`.github/workflows/ci.yml`) runs the test suite and static checks.

## Questions

Open a [Discussion](https://github.com/belowzeroff/qbase/discussions) for questions,
or an [issue](https://github.com/belowzeroff/qbase/issues) for concrete bugs and
feature requests.

## License

By contributing, you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE).
