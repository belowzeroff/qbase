# py

Optional thin wrappers around [PyKX](https://code.kx.com/pykx/).

```q
.py.eval[code]      / evaluate Python code via PyKX
.py.import[module]  / import a Python module
.py.toq[x]          / convert a PyKX/foreign object to a native q value
.py.toPandas[t]     / convert a q table to a Pandas DataFrame (as a PyKX object)
.py.toArrow[t]       / convert a q table to a PyArrow Table (as a PyKX object)
```

PyKX must be installed and its q interface (`pykx.q`) loaded into the process separately
— it is **not** bundled with qbase. `.py.init` detects whether it's available
(`.py.cfg.enabled`) and logs a warning if not; every `.py.*` function then throws
`PyKxNotAvailableException` so callers fail fast with a clear message instead of a
cryptic error. `.py.toPandas` / `.py.toArrow` are illustrative wrappers — verify against
your installed PyKX version.
