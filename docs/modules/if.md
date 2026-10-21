# if

Interface / implementation binding: lets a library declare a function it needs without
depending on which concrete library provides it.

```q
.if.setImplementationsFor[lib; ifMapping]  / register ifFunc->implFunc rows for a library
.if.bindInterfacesFor[lib; overwrite]      / bind that library's registered implementations
.if.bindAllInterfaces[overwrite]           / bind every registered library's interfaces
```

Implementations are stored in `.if.cfg.interfaces` (keyed `lib`/`ifFunc`, with `implFunc`).
`.if.bindInterfacesFor` throws `MissingInterfaceImplementationException` if any interface
for that library has no implementing function configured. Binding with `overwrite:0b`
leaves an existing binding untouched; `1b` replaces it. This is how `require` logs via
`.log.if.*` before `log` itself is loaded — the interfaces fall back silently if no
implementation is bound yet.
