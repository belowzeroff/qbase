// qbase Tests - csv (CSV parsing and writing)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`csv;


// -- .csv.load / .csv.parse ---------------------------------------------------

/ Builds a small CSV fixture under 'dir' with a comment line, a blank line, a header row
/ (sym,qty,amt) and 3 data rows, matching the types string "SIJ"
.t.i.buildCsvLoadFixture:{[dir]
    system "mkdir -p ",1_ string dir;

    lines:("/ comment line - ignored";"";"sym,qty,amt";"a,10,100";"b,20,200";"c,30,300");
    (` sv dir,`data.csv) 0: lines;
 };

.t.csv_load_returnsExpectedTable:{[]
    dir:`:/tmp/qbase_test_csv_load;

    .t.i.buildCsvLoadFixture dir;

    actual:.[.csv.load; ("SIJ"; ` sv dir,`data.csv); {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    expected:([] sym:`a`b`c; qty:10 20 30i; amt:100 200 300j);
    .test.assert.equals[expected; actual];
 };

.t.csv_load_raisesForNonPathArgument:{[]
    .test.assert.raisesLike[.csv.load; ("SIJ"; "/tmp/qbase_test_csv_not_a_path.csv"); "*IllegalArgumentException*"];
 };

/ One data line matches the expected field count (3), the other does not - i.e. "any w" is
/ true - so the corrupt-length-line branch ('CorruptCsvDataException) is taken
.t.csv_parse_raisesCorruptCsvDataException_whenSomeLinesWrongLength:{[]
    lines:("a,1,100"; "b,2");

    .test.assert.raisesLike[.csv.parse; ("SIJ"; lines); "*CorruptCsvDataException*"];
 };

/ None of the data lines match the expected field count (3) - i.e. "any w" is false for every
/ line consistently - so the types-mismatch branch ('TypesMismatchException) is taken
.t.csv_parse_raisesTypesMismatchException_whenAllLinesWrongLength:{[]
    lines:("a,1"; "b,2"; "c,3");

    .test.assert.raisesLike[.csv.parse; ("SIJ"; lines); "*TypesMismatchException*"];
 };


// -- .csv.write ----------------------------------------------------------------

.t.csv_write_roundTripsSimpleTable:{[]
    dir:`:/tmp/qbase_test_csv_write;
    path:` sv dir,`rt.csv;

    system "mkdir -p ",1_ string dir;

    simpleT:([] a:`x`y`z; b:1 2 3i; c:10 20 30j);

    actual:.[{[p;d] .csv.write[p;d]; .csv.load["SIJ"; p]}; (path; simpleT); {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[simpleT; actual];
 };

.t.csv_write_raisesForNonTableData:{[]
    .test.assert.raisesLike[.csv.write; (`:/tmp/qbase_test_csv_not_used.csv; "not a table"); "*IllegalArgumentException*"];
 };

.t.csv_write_raisesForNonPathPath:{[]
    simpleT:([] a:1 2 3);

    .test.assert.raisesLike[.csv.write; ("not a path"; simpleT); "*IllegalArgumentException*"];
 };

/ Column 'b' holds values that are themselves lists of lists of varying length - a genuinely
/ nested column that '.Q.ty' flags as unsupported (returns a space for the column). The nested
/ column check happens before any disk I/O, so no fixture file/folder is created by this test
.t.csv_write_raisesUnsupportedColumnTypeException_forNestedColumn:{[]
    nestedCol:((1 2; 3 4 5); (6; 7 8));
    nestedT:([] a:1 2; b:nestedCol);

    .test.assert.raisesLike[.csv.write; (`:/tmp/qbase_test_csv_nested_unused.csv; nestedT); "*UnsupportedColumnTypeException*"];
 };
