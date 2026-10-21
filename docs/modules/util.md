# util

General-purpose utilities that don't fit a more specific library.

```q
.util.round[p; x]          / round a real/float to 'p' decimal places
.util.trim[str]            / trim spaces, tabs, newlines and carriage returns
.util.isEmpty[x]           / null-or-empty check for atoms, lists and dicts
.util.pivot[t; c; r; d]    / pivot an unkeyed, unenumerated table
.util.system[cmd]          / system wrapper that raises SystemCallFailedException on failure
.util.gc[]                 / .Q.gc with timing/logging of memory returned to the OS
```

`.util.isEmpty` is a safer `null` check that also catches empty lists and dictionaries.
`.util.pivot` expects an unkeyed table with no enumerated columns. `.util.getTableCounts`
and `.util.clearTable` only work on in-memory tables in the root namespace.
`.util.isTlsAvailable` reports whether OpenSSL has been loaded into the process (used by
`http` to decide if HTTPS is possible).
