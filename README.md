# qbase — kdb+/q Core Libraries & Framework

`qbase` is a batteries-included foundation for building kdb+/q applications: a boot
sequence, a dependency loader (`require`), structured logging, command-line argument
parsing, and a broad set of utility libraries (HTTP, IPC, CSV, cron, timezones,
compression and more).

> `qbase` is a rebranded, actively maintained fork of
> [BuaBook/kdb-common](https://github.com/BuaBook/kdb-common) (Apache-2.0).
> See [ROADMAP.md](ROADMAP.md) for the modernisation plan (v2.0 architecture).

## Requirements

* kdb+ **>= 4.0** (verified on 4.1)

## Quick Start

1. Clone the repository and `cd` into the root folder.
2. Start kdb+ with `boot.q`:
   * Linux / macOS: `q $(pwd)/boot.q`
   * Windows: `q %CD%\boot.q`

This loads the `cargs`, `log` and `ns` core libraries automatically during boot.
Additional libraries can be loaded via the `--load-libs` command-line argument, or at
runtime with `.require.lib`.

### Example Output

```bash
> rlwrap $QHOME/l64/q $(pwd)/boot.q
...
Application root: /home/me/git/qbase | qbase root: /home/me/git/qbase
Library root location refreshed [ File Count: 36 ]
...
Logging enabled [ Level: INFO ] [ Logger: .log.loggers.basic ] [ Formatter: .log.formatter.default ]

2026.07.20 08:58:26.877 INFO  pid-727 me 0 Initialised library: log
q)
```

## Libraries

**Core**

| Module | Description |
|--------|-------------|
| `require` | Dependency-aware code loader |
| `log` / `log.loggers` | Structured, level-based logging |
| `cargs` | Command-line argument parsing |
| `ns` | Namespace management helpers |
| `if` | Interface / implementation binding |
| `type` | Type checking and normalisation |
| `util` | General utilities |

**Data & Time**

| Module | Description |
|--------|-------------|
| `time` / `time.util` | Time accessors and utilities |
| `tz` | Timezone conversion (Olson/tz database) |
| `convert` | Type conversion functions |
| `csv` | CSV parsing and writing |
| `rand` | Random data generation |

**I/O & Files**

| Module | Description |
|--------|-------------|
| `file` / `file.hdb` / `file.kdb` | Filesystem and HDB helpers |
| `compress` | HDB compression (qIPC, gzip, snappy, lz4hc, ZSTD) |
| `os` | OS-specific functionality |
| `so` | Shared-object function manager |
| `terminal` | Console management |
| `env` | Environment variable manager |

**Networking & Integrations**

| Module | Description |
|--------|-------------|
| `ipc` | Inter-process communication |
| `http` / `http.status` | HTTP client |
| `wsc` | WebSocket client |
| `cron` | Job scheduler |
| `event` | Internal event management |
| `mail` | E-mail sending via `mailx` |
| `slack` | Slack notifications via webhook |

Module APIs are documented inline with [qdoc](https://github.com/BuaBook/kdb-common/wiki)
annotations; the upstream [wiki](https://github.com/BuaBook/kdb-common/wiki) still applies
to the module APIs until the dedicated docs portal lands (ROADMAP Phase 4).

## License

Licensed under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for attribution.

Original work © Sport Trades Ltd and Jaskirat Rajasansir; `qbase` modifications
© 2026 Evgen Bielozorov.
