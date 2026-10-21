# rand

Random data generation for table schemas, plus OS-entropy-backed random atoms.

```q
.rand.generate[schema; rows]  / 'rows' random rows matching a table schema
.rand.dr.short[]              / short generated from /dev/random
.rand.dr.int[]                / integer generated from /dev/random
.rand.dr.long[]                / long generated from /dev/random
.rand.dr.guid[]                / GUID generated from /dev/random
```

`.rand.generate` throws `IllegalArgumentException` if `schema` isn't a table, or `rows`
isn't a positive whole number. Generated values are bounded by `.rand.types` (e.g. dates
and timestamps cap out at 2030.01.01, symbols are 4 characters). The `.rand.dr.*`
functions open `/dev/random` directly via `hopen`; by default a handle is opened and
closed per call — set `.rand.cfg.keepDevRandomOpen` to keep one handle open across calls.
