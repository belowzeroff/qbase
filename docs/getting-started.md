# Getting Started

## Requirements

- kdb+ **>= 4.0** (verified on 4.1), with `q` on your `PATH`

## Install

```bash
curl -sSL https://raw.githubusercontent.com/belowzeroff/qbase/master/install.sh | bash
```

This installs qbase to `~/.qbase` (override with `$QBASE_HOME`). You can also install
from a local checkout — useful offline or for development:

```bash
QBASE_SRC=/path/to/qbase-checkout QBASE_HOME=~/.qbase bash install.sh
```

## Run your first process

```bash
q ~/.qbase/boot.q
```

`boot.q` initialises `require` and loads the core libraries (`log`, `cargs`, `ns`):

```text
Application root: ~/.qbase | qbase root: ~/.qbase
...
2026.07.21 08:58:26.877 INFO  pid-727 me 0 Initialised library: log
q)
```

## Load more libraries

At boot:

```bash
q ~/.qbase/boot.q --load-libs http,ipc
```

Or at runtime:

```q
.require.lib`http
```

## Next steps

- Try the [examples](https://github.com/belowzeroff/qbase/tree/master/examples)
  (a REST microservice, a tickerplant subscriber, a PyKX pipeline).
- Read the [Core Concepts](core-concepts.md).
