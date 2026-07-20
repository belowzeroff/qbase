# qbase Tests

Unit tests for each module, built on a lightweight `.test.assert` framework
(planned in [ROADMAP](../ROADMAP.md) — Phase 2).

Planned layout:

* `test_boot.q` — boot sequence
* `test_cargs.q` — command-line argument parsing
* `test_log.q` — logging levels
* `test_require.q` — namespace isolation and dependency loading

The suite will be runnable locally and in CI (GitHub Actions).
