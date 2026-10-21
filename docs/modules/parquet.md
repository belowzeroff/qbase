# parquet

Optional Apache Parquet read/write via the
[`arrowkdb`](https://github.com/KxSystems/arrowkdb) extension.

```q
.parquet.write[path; t]  / write a q table to a Parquet file
.parquet.read[path]      / read a Parquet file into a q table
```

`arrowkdb` must be installed and loaded separately — it is **not** bundled with qbase.
`.parquet.init` detects whether it's available (`.parquet.cfg.enabled`) and logs a warning
if not; every `.parquet.*` function then throws `ArrowKdbNotAvailableException` until
`arrowkdb` is loaded. These are thin, illustrative wrappers — verify the exact
`.arrowkdb.pq.*` call signatures against the arrowkdb version you install.
