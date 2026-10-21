# log.loggers

The concrete output formatters used by `log` — selected via `.log.cfg.logger`.

```q
.log.loggers.basic[formatter; fd; lvl; message]    / plain text line
.log.loggers.color[formatter; fd; lvl; message]    / level highlighted per .log.levels
.log.loggers.syslog[formatter; fd; lvl; message]   / adds a "<priority>" prefix for systemd-cat
.log.loggers.json[formatter; fd; lvl; message]     / one JSON object per line
```

Each logger is called by `log` with a formatter function, the output file descriptor,
the level and the message, and writes a single line. `.log.loggers.json` does not apply
the formatter's slf4j-style `{}` parameter substitution — it logs `date`, `time`, `level`,
`processId`, `user`, `handle` and `message` (plus any configured context fields) as a
single JSON object instead. See the [log module guide](log.md) for choosing a logger.
