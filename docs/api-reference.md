# API Reference

Every qbase function is annotated inline with [qdoc](https://github.com/BuaBook/kdb-common/wiki)
comments describing parameters, return values and exceptions:

```q
/ Loads the specified library and initialises it
/  @param lib (Symbol) The library to load
/  @throws LibraryDoesNotExistException If no files are found for the library
.require.lib:{[lib] ... };
```

Until a generated API browser is published, read the annotations directly in
[`src/`](https://github.com/belowzeroff/qbase/tree/master/src), or use the per-module
guides in this site.
