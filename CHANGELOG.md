# Changelog

All notable changes to qbase are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2026-10-20

A patch release: full test coverage across every module (which caught two previously-latent
bugs), a security hardening pass over the library's shell-facing code, two inherited-from-
upstream bug fixes, and two inherited-from-upstream feature extensions. No breaking changes;
all new options default to the existing behaviour.

### Added

- **`.so.findSharedObject`** now falls back to OS-standard shared library locations
  (`.os.defaultSharedObjectPaths`, e.g. `/usr/lib`, `/usr/local/lib`, `/opt/homebrew/lib` on
  macOS) when the configured env var (`.os.sharedObjectEnvVar`) does not resolve a match,
  matching the fix proposed upstream for
  [BuaBook/kdb-common#48](https://github.com/BuaBook/kdb-common/issues/48).
- **`.compress.partition`** gained an `ignoreTables` option to exclude specific tables from a
  HDB partition compression, and **`.compress.splay`** gained `compressColumns` /
  `ignoreColumns` options to compress or copy only a specific subset of a splay's columns
  (mutually exclusive), matching the fixes proposed upstream for
  [BuaBook/kdb-common#82](https://github.com/BuaBook/kdb-common/issues/82) and
  [BuaBook/kdb-common#83](https://github.com/BuaBook/kdb-common/issues/83).

- **Test coverage** now spans every module in `src/` (previously 14 of 33) — `tests/` grew from
  54 to 235 cases. Writing these tests surfaced the two bugs listed below, each previously
  unverified by any test.

### Fixed

- **`.ns.protectedExecute`** now returns the standard `` `isError`errorMsg`` error dictionary
  instead of raising an unhandled exception when the target function reference does not exist,
  matching the fix proposed upstream for
  [BuaBook/kdb-common#115](https://github.com/BuaBook/kdb-common/issues/115).
- **`.util.trim`** no longer raises a `type` error on an empty or all-whitespace string; it now
  returns `""` for both.
- **`.time.nowForFileName`** no longer omits leading zeros from the millisecond component,
  which previously shortened its documented fixed-width `yyyymmdd_hhMMss_SSS` format by 1-2
  characters whenever the millisecond value was below 100 (roughly 1 call in 10).
- **`.file.kdb.getLength`** no longer returns `0` for an ordinary single-typed list file (the
  `0xfe20` magic, e.g. any plain non-enumerated numeric or sym column) on kdb+ builds where that
  format's header does not encode the element count (confirmed on kdb+ 4.1, 2025.07.09, where
  those header bytes are always zero regardless of length). The length is now derived from the
  file size instead of the unreliable header field for this magic; the other two supported
  magics (`0xff01`, `0xfd20`) were already correct and are unaffected.

### Security

- **`.os.run`** and its per-OS command templates (`mkdir`, `rm`, `rmF`, `mv`, `cp`, `ln`,
  `rmFolder`, `cpFolder`, `pidCheck`, `tail`, `cpuAssign`, `readlink`, ...) previously spliced
  their path/text argument directly into a shell command string with no escaping — any
  argument containing shell metacharacters (`` ` ``, `;`, `$()`, `|`, ...) could break out and
  run arbitrary commands wherever that argument came from untrusted input. They now pass every
  argument through a new `.os.i.escapeSQ` single-quote-escaping helper before it reaches the
  shell. The Windows (`.os.w.*`) templates get an analogous best-effort, **unverified** fix (see
  the new README Security section). Also removed a duplicate `.os.w.rmFolder` definition.
- **`.mail.send`** (`mailx`/`mutt` backends) had the same class of injection via the `subject`,
  `from`, `cc`/`bcc`/`to` addresses and attachment paths — in particular, a `subject` containing
  a double quote could break out of its `-s "..."` fragment entirely. All of these are now
  escaped with `.os.i.escapeSQ` before the command is built. The existing
  "attachment path contains a space" validation is kept as defense-in-depth.
- **`.slack.notify`** logged the full Slack webhook URL — a secret — at both debug and warn
  level. It now masks everything after the host by default (`.slack.i.maskUrl`); set the new
  `.slack.cfg.logWebhookUrl:1b` to opt back into unmasked logging.
- Added a **Security** section to the README covering these changes and the library's
  remaining security-relevant defaults (no built-in IPC authentication in `boot.q`, the
  Windows-escaping caveat, and the `install.sh` `curl | bash` trust assumption).

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

[2.0.1]: https://github.com/belowzeroff/qbase/compare/v2.0.0...master
[2.0.0]: https://github.com/belowzeroff/qbase/releases/tag/v2.0.0
