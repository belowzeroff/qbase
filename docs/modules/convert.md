# convert

Type conversion helpers for the cases `$` doesn't cover directly.

```q
.convert.msToTimespan[x]          / milliseconds -> Timespan
.convert.epochMsToTimestamp[x]    / JS/UNIX epoch milliseconds -> Timestamp
.convert.hsymToString[x]          / `:/path -> "/path"
.convert.stringToHsym[x]          / "/path" -> `:/path
.convert.listToString[list]       / plain list -> comma-separated string, for logging
.convert.tableToHtml[tbl]         / table -> HTML <table> string
```

`.convert.listToString` assumes a flat, non-nested list; `.convert.genericListToString`
is the more defensive variant that string-ifies every element individually.
`.convert.bytesToLong` throws `TooManyBytesException` for more than 8 bytes.
`.convert.tableToHtml` throws `IllegalArgumentException` if not given a table and
unkeys a keyed table before rendering.
