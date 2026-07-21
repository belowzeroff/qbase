# require

The dependency-aware code loader that underpins qbase.

```q
.require.lib`http         / load + init (idempotent)
.require.libNoInit`http   / load without init
.require.libForce`http    / force reload
.require.loaded[]         / loaded library names
.require.isLoaded`http    / boolean
```

## How libraries are found

`require` scans the root directory (`.require.location.root`) for files matching a
library name and the suffixes in `.require.fileSuffixes` (`.q`, `.k`, `.*.q`, ...). So
library `file` loads `file.q`, `file.hdb.q` and `file.kdb.q`.

## State & cycles

`.require.loadedLibs` tracks load/init state and timestamps. A library that is already
loaded is not reloaded, which also breaks dependency cycles.

## Init functions

If a library `foo` defines `.foo.init`, it runs once when the library is first loaded.
Init errors are caught and reported with a backtrace.
