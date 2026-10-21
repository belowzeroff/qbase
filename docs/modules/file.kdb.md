# file.kdb

Reads a kdb+ on-disk file's header directly (via `read1`) to get its type, attribute and
element count without loading the whole file with `get`.

```q
.file.kdb.getSummary[file]              / type, attribute and length in one call
.file.kdb.getType[file]                 / file's kdb+ type, from the header
.file.kdb.getAttribute[file]            / applied attribute (`s`u`p`g or null), from the header
.file.kdb.getLength[file]               / element count
.file.kdb.getSymEnumerationTarget[file] / enumeration target symbol, for symbol files
```

Every function reads only the first 4096 bytes of the file (assumed to be the smallest
storage block size) and interprets them based on the file's "magic number" (`0xff01`,
`0xfe20` or `0xfd20`). `.file.kdb.getSymEnumerationTarget` throws
`FileIsNotAnEnumerationException` if the file isn't a symbol list or enumerated symbol
list type.

NOTE: on some kdb+ builds (confirmed on 4.1, 2025.07.09) the header's "length" field for
the `0xfe20` ("single-typed list") magic is always zero rather than the real element
count, so `.file.kdb.getLength` does not trust it for that magic — it derives the count
from the file size instead (`(hcount file - 16) div elementByteWidth`).
