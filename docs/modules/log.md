# log

Level-based logging with pluggable formatters and loggers.

## Levels

`TRACE` < `DEBUG` < `INFO` < `WARN` < `ERROR` < `FATAL`. Set the active level:

```q
.log.setLevel`DEBUG
.log.isLoggingAt`INFO    / 1b if INFO is currently being logged
```

Messages below the active level become no-ops (near-zero overhead).

## Logging

```q
.log.info "hello"
.log.info ("user {} logged in from {}"; `alice; "10.0.0.1")   / slf4j-style
```

## JSON output

Set `$KDB_LOG_JSON` (or pass `-logJson`) to emit one JSON object per line — ideal for
Vector, Fluentd, Loki or ELK:

```json
{"date":"2026-07-21","time":"08:58:26.877","level":"INFO","processId":"pid-727","user":"me","handle":0,"message":"user alice logged in from 10.0.0.1","trace_id":"abc123"}
```

## Contextual fields

Attach fields that appear on every log line (text and JSON):

```q
.log.setContext `trace_id`span_id`user!("abc123"; "def456"; `alice)
.log.addContext[`request_id; "r-42"]
.log.clearContext[]
```
