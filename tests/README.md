# qbase Tests

Unit tests for the core modules, built on a lightweight `.test` assertion
framework (`tests/test.q`) with no dependencies beyond base q.

## Layout

| File | Purpose |
|------|---------|
| `test.q` | The `.test` framework: `assert.equals`, `assert.true`, `assert.false`, `assert.notEquals`, `assert.raises`, `assert.raisesLike`, and the runner |
| `run.q` | Loads the framework + every `test_*.q` case file, runs them, exits with the failure count |
| `run.sh` | Convenience wrapper around `q boot.q < tests/run.q` |
| `test_boot.q` | Boot / initialisation sequence |
| `test_cargs.q` | Command-line argument parsing |
| `test_log.q` | Logging levels |
| `test_require.q` | Dependency loading, namespace isolation, cycle guard |

Test cases are niladic functions in the `.t` namespace (e.g. `.t.cargs_parsesSimpleFlag`);
the runner discovers them automatically.

## Running locally

Requires a licensed kdb+ (>= 4.0) with `q` on your PATH (or set `$QBIN` to the binary):

```bash
tests/run.sh
# or explicitly:
QBIN=/path/to/q tests/run.sh
# or directly:
q boot.q < tests/run.q
```

The process **exits with the number of failing tests** (0 = all passed), so it gates CI.

## Running in Docker

kdb+ is proprietary and is not redistributed. Provide the free Linux edition at build time:

```bash
KDB_DOWNLOAD_URL="<free kdb+ linux zip url>" docker compose build
docker compose run --rm tests
```

A license (`kc.lic`) must be present in `QHOME` (or `QLIC`). See `Dockerfile` and
`docker-compose.yml`.

## CI

`.github/workflows/ci.yml` runs the suite on every push / pull request to `master`.
It requires two repository secrets:

* `KDB_DOWNLOAD_URL` — URL to a Linux kdb+ zip
* `KDB_LICENSE_B64` — base64-encoded `kc.lic`

Code-coverage collection is a planned follow-up (there is no mature line-coverage
tool for q).
