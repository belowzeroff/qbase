# Example: REST microservice

A minimal HTTP microservice built on qbase that serves process metrics as JSON,
using kdb+'s built-in `.z.ph` (HTTP GET) hook.

## Run

```bash
PORT=8080 ./run.sh
```

## Query

```bash
curl http://localhost:8080/           # service info
curl http://localhost:8080/metrics    # JSON metrics
curl -i http://localhost:8080/nope    # 404
```

Example response from `/metrics`:

```json
{"service":"qbase-microservice","status":"ok","uptime":"0D00:01:12.000","kdbVersion":4.1,"usedBytes":1234567,"heapBytes":67108864}
```

## How it works

`service.q` bootstraps qbase from `$QBASE_HOME` (set by `run.sh`), loads the `log`
and `cargs` libraries via `require`, then defines `.z.ph` to route GET requests and
return JSON. The listening port is supplied to q with `-p`.
