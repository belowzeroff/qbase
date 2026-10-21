# tz

Timezone conversion using an Olson/tz-database-derived CSV, following the approach at
[code.kx.com/v2/kb/timezones](https://code.kx.com/v2/kb/timezones/).

```q
.tz.getSupportedTimezones[]                       / all configured timezone IDs
.tz.utcToTimezone[timestamp; targetTimezone]      / UTC -> target zone
.tz.timezoneToUtc[timestamp; sourceTimezone]      / source zone -> UTC
.tz.timezoneToTimezone[timestamp; src; tgt]       / via UTC (slower than the direct forms)
```

On init, the library loads `timezone-config.csv` from `.tz.cfg.csvPath`, or, if unset,
`<require-root>/config/timezone/timezone-config.csv`, and throws `NoTzConfigException` if
that file isn't found. `.tz.utcToTimezone` / `.tz.timezoneToUtc` throw
`InvalidTargetTimezoneException` / `InvalidSourceTimezoneException` for a timezone ID not
present in `.tz.timezones`. `timestamp` may be a single value or a list.

```q
q).tz.utcToTimezone[2026.01.15D12:00:00.000000000; `Europe/London]
2026.01.15D12:00:00.000000000
```
