# Changelog

All notable changes to qbase are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-07-21

First release under the **qbase** name — a rebranded, modernised continuation of
[BuaBook/kdb-common](https://github.com/BuaBook/kdb-common). The public library API
(namespaces `.require`, `.log`, `.cargs`, ...) is unchanged, so existing kdb-common
code keeps working; this release adds tooling, tests, observability and documentation.

### Added

- **Test framework & CI** — a lightweight `.test` assertion framework and runner
  (`tests/`), 48 unit tests (boot, cargs, log, require, env, http, jschema and the
  PyKX/Parquet guards), a `Dockerfile` + `docker-compose.yml`, and a GitHub Actions
  workflow (`.github/workflows/ci.yml`).
- **Structured logging** — JSON logging (`.log.loggers.json`) with slf4j message
  formatting, plus contextual fields via `.log.context` / `.log.setContext` /
  `.log.addContext` / `.log.clearContext` (e.g. `trace_id`, `span_id`).
- **Configuration** — `.env` file loading via `.env.load`.
- **require** — `.require.loaded` and `.require.isLoaded` accessors over the module
  tracking table.
- **JSON schema validation** — a new `.jschema` module for validating `.j.k`-parsed data.
- **HTTP** — `.http.auth.bearer` and `.http.auth.basic` header helpers.
- **Python & Parquet** — new `.py` (PyKX) and `.parquet` (arrowkdb) modules with
  dependency guards that fail fast when the optional dependency is absent.
- **Installer** — `install.sh` (git or local install to `$QBASE_HOME`, with optional
  `$QINIT` integration).
- **Documentation** — a MkDocs Material site (`docs/`, `mkdocs.yml`) with a GitHub
  Pages deploy workflow.
- **Examples** — `examples/microservice` (REST/JSON metrics), `tickerplant-subscriber`
  and `pykx-pipeline`.
- **Licensing** — a `NOTICE` file and Apache-2.0 headers on every source file.

### Changed

- Rebranded from `kdb-common` to **qbase** (repository, README, boot banner).
- Verified on kdb+ 4.1; timezone database is current to 2100; compression uses the
  native kdb+ ZSTD algorithm.

### Notes

- No breaking changes to the runtime API versus kdb-common.
- Optional integrations (PyKX, arrowkdb, S3, AWS SigV4, async logging) are scaffolded
  or deferred — see the module documentation.

[2.0.0]: https://github.com/belowzeroff/qbase/releases/tag/v2.0.0
