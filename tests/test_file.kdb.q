// qbase Tests - file.kdb (on-disk kdb+ file header inspection)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE on '.require.lib': file.kdb.q has no library init of its own and is not required
// directly - '.require.lib`file' loads it anyway, because '.require''s file-discovery glob for
// a lib matches "<lib>.*.q" as well as "<lib>.q", and 'file.kdb.q' matches "file.*.q". So the
// same single '.require.lib`file' call used by test_file.q and test_file.hdb.q also loads
// file.kdb.q (confirmed by inspecting '.require.loadedLibs[`file]`files' after the call).

// NOTE on '.file.kdb.getLength': for a plain (non-symbol) single-typed list file - the
// "0xfe20 magic" case, e.g. a bare long/float list written via 'file set 10 20 30j' - this
// kdb+ build (4.1, 2025.07.09) does NOT encode the element count anywhere in the first 4096
// header bytes: the 16-byte header is byte-for-byte identical for a 3-element and a
// 300-element long list (verified directly with 'read1'), so the count is apparently implicit
// from the file size on this kdb+ version. '.file.kdb.getLength' assumes the count lives at
// header bytes 8-15 for this magic, which is incorrect here, so it returns 0 instead of the
// real count for this case (confirmed against both a standalone list file and a plain splayed
// numeric column file). This looks like a genuine behavioural bug/version-incompatibility in
// 'file.kdb.q' rather than a test-fixture problem - 'getType' and 'getAttribute' are unaffected
// and verified correct below. 'getLength' IS verified correct below against the cases where it
// does match ground truth on this build: atoms, a non-enumerated symbol list and an enumerated
// (splayed) symbol column.


// -- .file.kdb.getType / .file.kdb.getAttribute (plain + sorted long list) ------

.t.filekdb_getType_matchesRealTypeForPlainLongList:{[]
    dir:`:/tmp/qbase_test_filekdb_plain;
    f:` sv dir,`longlist;

    system "mkdir -p ",1_ string dir;
    f set 10 20 30j;

    actualType:.[.file.kdb.getType; enlist f; {[e] `FAILED}];
    realType:.[{[x] type get x}; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[realType; actualType];
 };

.t.filekdb_getAttribute_nullForPlainLongList:{[]
    dir:`:/tmp/qbase_test_filekdb_plainattr;
    f:` sv dir,`longlist;

    system "mkdir -p ",1_ string dir;
    f set 10 20 30j;

    actual:.[.file.kdb.getAttribute; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[`; actual];
 };

.t.filekdb_getAttribute_sForSortedLongList:{[]
    dir:`:/tmp/qbase_test_filekdb_sorted;
    f:` sv dir,`sortedlist;

    system "mkdir -p ",1_ string dir;
    f set `s#10 20 30j;

    actual:.[.file.kdb.getAttribute; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[`s; actual];
 };


// -- .file.kdb.getLength (atom, non-enumerated symbol list) ---------------------

.t.filekdb_getLength_matchesCountForAtom:{[]
    dir:`:/tmp/qbase_test_filekdb_atom;
    f:` sv dir,`atomfile;

    system "mkdir -p ",1_ string dir;
    f set 42j;

    actual:.[.file.kdb.getLength; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[1; actual];
 };

/ A plain (non-enumerated) symbol list hits the "atom or non-enumerated symbol list" (0xff01)
/ magic branch, where the length genuinely is encoded in the header on this kdb+ build
.t.filekdb_getLength_matchesCountForNonEnumeratedSymbolList:{[]
    dir:`:/tmp/qbase_test_filekdb_plainsym;
    f:` sv dir,`plainsym;

    system "mkdir -p ",1_ string dir;
    f set `a`b`c;

    actualLength:.[.file.kdb.getLength; enlist f; {[e] `FAILED}];
    actualType:.[.file.kdb.getType; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[3; actualLength];
    .test.assert.equals[11h; actualType];
 };


// -- .file.kdb.getSymEnumerationTarget -------------------------------------------

.t.filekdb_getSymEnumerationTarget_raisesForNonSymbolFile:{[]
    dir:`:/tmp/qbase_test_filekdb_nonsym;
    f:` sv dir,`longlist;

    system "mkdir -p ",1_ string dir;
    f set 10 20 30j;

    / Capture the outcome (error text on failure, result value if it unexpectedly succeeds)
    / BEFORE cleaning up, so the fixture is always removed regardless of what happened
    res:.[.file.kdb.getSymEnumerationTarget; enlist f; {[e] e}];

    system "rm -rf ",1_ string dir;

    .test.assert.true[(10h~type res) & res like "*FileIsNotAnEnumerationException*"];
 };

.t.filekdb_getSymEnumerationTarget_nullForNonEnumeratedSymbolList:{[]
    dir:`:/tmp/qbase_test_filekdb_plainsymenum;
    f:` sv dir,`plainsym;

    system "mkdir -p ",1_ string dir;
    f set `a`b`c;

    actual:.[.file.kdb.getSymEnumerationTarget; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[`; actual];
 };

/ Builds a minimal real splayed table with a symbol column enumerated against 'sym' - the
/ standard splay idiom also used in test_compress.q / test_file.hdb.q ('.Q.dpft')
.t.i.buildEnumeratedSymColumnFixture:{[root; d]
    system "mkdir -p ",1_ string root;

    `trade set ([] sym:`a`b`c; price:1.1 2.2 3.3);
    .Q.dpft[root; d; `sym; `trade];

    @[`.; `trade; _];

    :` sv root,(`$string d),`trade,`sym;
 };

.t.filekdb_getSymEnumerationTarget_returnsSymForEnumeratedColumn:{[]
    root:`:/tmp/qbase_test_filekdb_enumsym;
    d:2024.01.01;

    symFile:.t.i.buildEnumeratedSymColumnFixture[root; d];

    actual:.[.file.kdb.getSymEnumerationTarget; enlist symFile; {[e] `FAILED}];

    system "rm -rf ",1_ string root;

    .test.assert.equals[`sym; actual];
 };


// -- .file.kdb.getType / .file.kdb.getLength (enumerated splayed symbol column) ---

.t.filekdb_getType_getLength_matchGroundTruthForEnumeratedSymColumn:{[]
    root:`:/tmp/qbase_test_filekdb_enumsym2;
    d:2024.01.01;

    symFile:.t.i.buildEnumeratedSymColumnFixture[root; d];

    actualType:.[.file.kdb.getType; enlist symFile; {[e] `FAILED}];
    actualLength:.[.file.kdb.getLength; enlist symFile; {[e] `FAILED}];

    system "rm -rf ",1_ string root;

    .test.assert.equals[20h; actualType];
    .test.assert.equals[3; actualLength];
 };


// -- .file.kdb.getSummary ---------------------------------------------------------

.t.filekdb_getSummary_matchesIndividualFunctionResults:{[]
    root:`:/tmp/qbase_test_filekdb_summary;
    d:2024.01.01;

    symFile:.t.i.buildEnumeratedSymColumnFixture[root; d];

    summary:.[.file.kdb.getSummary; enlist symFile; {[e] `FAILED}];
    expType:.[.file.kdb.getType; enlist symFile; {[e] `FAILED}];
    expAttr:.[.file.kdb.getAttribute; enlist symFile; {[e] `FAILED}];
    expLength:.[.file.kdb.getLength; enlist symFile; {[e] `FAILED}];

    system "rm -rf ",1_ string root;

    .test.assert.equals[expType; summary`type];
    .test.assert.equals[expAttr; summary`attribute];
    .test.assert.equals[expLength; summary`length];
 };
