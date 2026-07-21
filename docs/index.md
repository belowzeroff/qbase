# qbase

`qbase` is a batteries-included foundation for building kdb+/q applications: a boot
sequence, a dependency loader (`require`), structured logging, command-line argument
parsing, and a broad set of utility libraries.

`qbase` is a rebranded, actively maintained fork of
[BuaBook/kdb-common](https://github.com/BuaBook/kdb-common), licensed under Apache-2.0.

## Where to next

- [Getting Started](getting-started.md) — install and run your first process
- [Core Concepts](core-concepts.md) — the boot sequence, dependency loading and interfaces
- [Module Guides](modules/log.md) — guides for the key libraries
- [API Reference](api-reference.md)

## Highlights

- **Dependency-aware loading** — `require` discovers and loads libraries on demand,
  tracking what is loaded to avoid re-imports and break dependency cycles.
- **Structured logging** — level-based logging with text and JSON output and
  contextual fields (`trace_id`, `span_id`, ...).
- **Batteries included** — HTTP, IPC, CSV, cron, timezones, compression, `.env`
  configuration, JSON schema validation and more.

Requires **kdb+ >= 4.0** (verified on 4.1).
