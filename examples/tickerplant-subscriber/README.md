# Example: tickerplant subscriber

A market-data subscriber built on qbase. It connects to a kdb+ tickerplant,
subscribes to all tables/symbols, and logs the rows received per update via the
standard `.u.upd` callback.

## Prerequisites

A running tickerplant — for example [KxSystems/kdb-tick](https://github.com/KxSystems/kdb-tick):

```bash
q tick.q sym . -p 5010
```

## Run

```bash
TP_HOST=localhost TP_PORT=5010 ./run.sh
```

The subscriber connects (via the qbase `ipc` library / `hopen`), sends
`.u.sub[`;`]` to subscribe to everything, then stays alive processing updates.
If it cannot reach the tickerplant it logs the error and exits with status 1.

## How it works

`subscriber.q` bootstraps qbase from `$QBASE_HOME`, loads `log`/`cargs`/`ipc`,
defines `.u.upd` to handle incoming data, and opens a handle to the tickerplant.
