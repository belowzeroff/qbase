# csv

CSV parsing and writing.

```q
.csv.load[types; path]   / load a CSV file as a table
.csv.parse[types; lines] / parse already-read CSV lines as a table
.csv.write[path; data]   / write a table to a CSV file
```

`types` is a type string, one character per column (as used by kdb+'s `0:`). Empty lines
and lines starting with `/` are ignored on load. `.csv.parse` throws
`CorruptCsvDataException` if some (but not all) rows have the wrong column count, or
`TypesMismatchException` if every row consistently has a different column count than
`types` expects. `.csv.write` throws `UnsupportedColumnTypeException` for any nested-list
column.

```q
q).csv.parse["SIJ"; ("sym,qty,amt";"a,10,100";"b,20,200")]
sym qty amt
-----------
a   10  100
b   20  200
```
