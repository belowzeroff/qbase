# so

Loads functions from shared objects (`.so`/`.dll`/`.dylib`) at runtime via kdb+'s `2:`.

```q
.so.findSharedObject[soName]                              / locate a shared object by name
.so.loadFunction[soName; soFunctionName; soFunctionArgs]   / load+bind a function from it
```

`.so.findSharedObject` searches the OS's shared-object path environment variable first
(`LD_LIBRARY_PATH` / `DYLD_LIBRARY_PATH` / `PATH`), then falls back to OS-standard default
locations (`.os.defaultSharedObjectPaths`) if nothing matches; it returns a null symbol,
and logs a warning, if no match is found anywhere. `.so.loadFunction` throws
`SharedObjectNotFoundException` if the shared object can't be located, binds the loaded
function into `.so.cfg.targetNs` (default `` `.so.libs ``), and will not reload a function
that's already loaded. Successfully loaded functions are tracked in `.so.loaded`.
