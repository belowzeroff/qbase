# cargs

Command-line argument parsing on top of `.Q.opt`.

```q
.cargs.get[]              / parsed user arguments (.z.x) as a dict
.cargs.getWithInternal[] / includes kdb+ internal args (.z.X)
```

`--param value` becomes `` `param!"value" ``; multi-token values are space-joined.
Results are cached after first use.

```bash
q boot.q --load-libs http,ipc --debug
```

```q
q).cargs.get[]
load-libs| "http,ipc"
debug    | ""
```
