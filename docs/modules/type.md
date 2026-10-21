# type

Type checking and normalisation helpers used throughout qbase.

```q
.type.isString[x]          / 10h~type x
.type.isTable[x]           / .Q.qt wrapper
.type.isFile[x]            / path exists and is a file
.type.isFunction[x]        / any of the lambda/operator/projection type codes
.type.ensureSymbol[x]      / coerce atoms/dates/numbers/booleans/guids to a symbol
.type.ensureString[x]      / coerce almost anything to a string
```

`.type.is*Type*` and `.type.is*Type*List` functions (e.g. `.type.isLong`,
`.type.isLongList`) are generated on `.type.init` for every type in `.type.const.types`,
built from a string template for performance rather than hand-written. `.type.isFile` and
`.type.isFolder` both throw `IllegalArgumentException` if given something that isn't a
file path. `.type.ensureString` recurses into dicts, tables and typed lists via `.Q.s1`
or comma-joining, rather than just calling `string`.
