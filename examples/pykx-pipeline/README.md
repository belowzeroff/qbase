# Example: hybrid q + Python (PyKX) pipeline

A data pipeline that moves a q table into Python as a Pandas DataFrame, performs a
transformation there, and brings the result back into q — using the qbase `.py`
(PyKX) integration module.

## Prerequisites

* [PyKX](https://code.kx.com/pykx/): `pip install pykx`
* PyKX's q interface (`pykx.q`) loadable in the process

## Run

```bash
./run.sh
```

If PyKX is not available the example logs a clear message and exits cleanly (0),
so it is safe to run anywhere.

## How it works

`pipeline.q` bootstraps qbase, loads the `py` library and checks `.py.cfg.enabled`.
When PyKX is present it converts a sample table with `.py.toPandas`, runs a grouped
aggregation in Python via `.py.eval`, and converts the result back with `.py.toq`.
