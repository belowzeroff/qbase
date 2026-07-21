# Core Concepts

## Boot sequence

`boot.q` locates the qbase root from its own path, loads `src/require.q`, initialises
`require`, and loads the core libraries (`log`, `cargs`, `ns`). Command-line boot modes:

- `--load-libs a,b,c` — load additional libraries at boot
- `--script file.q` — load a script, optionally run a function (`--script-func`), then exit
- `--debug` — enable error-trap mode and keep the process alive after `--script`

Set `$KDB_APPLICATION_ROOT` to run qbase from one location while your application root
is elsewhere.

## Dependency loading (`require`)

Libraries live in `src/` as `.q` files. `require` discovers them and loads on demand:

```q
.require.lib`http        / load + initialise a library (idempotent)
.require.libNoInit`http  / load without running its init
.require.libForce`http   / force reload
.require.loaded[]        / list loaded libraries
.require.isLoaded`http   / is a library loaded?
```

Loaded state is tracked in `.require.loadedLibs`, which prevents repeat imports and
breaks dependency cycles (a library already being loaded is not loaded again).

A library `foo` is a file `src/foo.q` that defines the `.foo` namespace and, optionally,
a `.foo.init` function run once on load.

## Interfaces (`if`)

The `if` library lets libraries declare interface functions and bind implementations at
runtime. For example, `require` logs via `.log.if.*` interface functions that are bound
to the real `log` implementation once `log` is loaded, and fall back to simple stdout
logging before that.

## Logging

See the [log module guide](modules/log.md). Logging is level-based (`TRACE` → `FATAL`),
supports text and JSON output, and contextual fields.
