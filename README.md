# qbase — kdb+/q Core Libraries & Framework

`qbase` is a batteries-included foundation for building kdb+/q applications: a boot
sequence, a dependency loader (`require`), structured logging, command-line argument
parsing, and a broad set of utility libraries (HTTP, IPC, CSV, cron, timezones,
compression and more).

> `qbase` is a rebranded, actively maintained fork of
> [BuaBook/kdb-common](https://github.com/BuaBook/kdb-common) (Apache-2.0).

## Requirements

* kdb+ **>= 4.0** (verified on 4.1)

## Install

```bash
curl -sSL https://raw.githubusercontent.com/belowzeroff/qbase/master/install.sh | bash
```

Installs to `~/.qbase` (override with `$QBASE_HOME`), or clone the repository and use it
in place. See [`install.sh`](install.sh) for options (offline install via `QBASE_SRC`,
`$QINIT` integration).

## Quick Start

Start kdb+ with `boot.q`:

* Linux / macOS: `q ~/.qbase/boot.q`  (or `q $(pwd)/boot.q` from a checkout)
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
| `log` / `log.loggers` | Structured, level-based logging (text + JSON, contextual fields) |
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
| `env` | Environment variables and `.env` file loading |
| `parquet` | Apache Parquet read/write via `arrowkdb` (optional) |

**Networking & Integrations**

| Module | Description |
|--------|-------------|
| `ipc` | Inter-process communication |
| `http` / `http.status` | HTTP client (TLS, proxy, Basic/Bearer auth) |
| `jschema` | JSON schema validation for `.j.k`-parsed data |
| `wsc` | WebSocket client |
| `cron` | Job scheduler |
| `event` | Internal event management |
| `mail` | E-mail sending via `mailx` |
| `slack` | Slack notifications via webhook |
| `py` | PyKX (Python) integration (optional) |

Module APIs are documented inline with [qdoc](https://github.com/BuaBook/kdb-common/wiki)
annotations in each source file.

## Documentation

A documentation site is built with MkDocs (see [`docs/`](docs) and [`mkdocs.yml`](mkdocs.yml)):
Getting Started, Core Concepts, Module Guides and API Reference. It is published to GitHub
Pages on each release.

## Examples

Runnable examples live in [`examples/`](examples):

* [`microservice/`](examples/microservice) — a REST service exposing JSON metrics
* [`tickerplant-subscriber/`](examples/tickerplant-subscriber) — a market-data subscriber
* [`pykx-pipeline/`](examples/pykx-pipeline) — a hybrid q + Python pipeline

## Testing

See [`tests/`](tests). Run the suite with `tests/run.sh` (48 tests, green on kdb+ 4.1).

## License

Licensed under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for attribution.

Original work © Sport Trades Ltd and Jaskirat Rajasansir; `qbase` modifications
© 2026 Evgen Bielozorov.
