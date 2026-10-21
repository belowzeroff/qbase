// qbase Tests - file (file/folder manipulation)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: '.file.getCwd' is skipped - it is a thin wrapper around '.os.run[`pwd;::]', already
// indirectly covered by os.q's own tests. '.file.loadDir' is skipped - it actually 'load's a
// file into the running process, which could have unintended side effects on this shared test
// process, so it is deliberately not exercised here.

.require.lib`file;


/ Builds a small fixture tree at 'dir': 2 plain files directly inside, plus a 'sub' folder
/ containing its own file
.t.i.buildFileTreeFixture:{[dir]
    system "mkdir -p ",1_ string dir;

    (` sv dir,`a.txt) 0: enlist "hello";
    (` sv dir,`b.txt) 0: enlist "world";
    (` sv dir,`sub`c.txt) 0: enlist "nested";
 };


// -- .file.ls / .file.listFolder ------------------------------------------------

.t.file_ls_listsDirectContentsNotQualified:{[]
    dir:`:/tmp/qbase_test_file_ls;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.ls; enlist dir; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[`a.txt`b.txt`sub; asc actual];
 };

.t.file_ls_raisesForNonPathArgument:{[]
    .test.assert.raisesLike[.file.ls; enlist "not a path"; "*IllegalArgumentException*"];
 };


// -- .file.listFolderPaths -------------------------------------------------------

.t.file_listFolderPaths_returnsFullyQualifiedPaths:{[]
    dir:`:/tmp/qbase_test_file_paths;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.listFolderPaths; enlist dir; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    expected:asc ` sv/: dir,/:`a.txt`b.txt`sub;
    .test.assert.equals[expected; asc actual];
 };


// -- .file.find / .file.findFilePaths --------------------------------------------

.t.file_find_matchesStringGlob:{[]
    dir:`:/tmp/qbase_test_file_find1;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.find; ("*.txt"; dir); {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[`a.txt`b.txt; asc actual];
 };

.t.file_find_matchesSymbolGlobWrappedInWildcards:{[]
    dir:`:/tmp/qbase_test_file_find2;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.find; (`a; dir); {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[enlist `a.txt; actual];
 };

.t.file_find_raisesForNonPathFolder:{[]
    .test.assert.raisesLike[.file.find; ("*"; "not a path"); "*IllegalArgumentException*"];
 };

.t.file_findFilePaths_returnsFullyQualifiedMatches:{[]
    dir:`:/tmp/qbase_test_file_find3;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.findFilePaths; (`a; dir); {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[enlist ` sv dir,`a.txt; actual];
 };

.t.file_findFilePaths_raisesForNonPathFolder:{[]
    .test.assert.raisesLike[.file.findFilePaths; (`a; "not a path"); "*IllegalArgumentException*"];
 };


// -- .file.ensureDir --------------------------------------------------------------

.t.file_ensureDir_createsMissingFolder:{[]
    dir:`:/tmp/qbase_test_file_ensuredir;
    newDir:` sv dir,`created;

    system "mkdir -p ",1_ string dir;

    existedBefore:.[.type.isFolder; enlist newDir; {[e] 0b}];
    result:.[.file.ensureDir; enlist newDir; {[e] `FAILED}];
    existsAfter:.[.type.isFolder; enlist newDir; {[e] 0b}];

    system "rm -rf ",1_ string dir;

    .test.assert.false existedBefore;
    .test.assert.equals[newDir; result];
    .test.assert.true existsAfter;
 };

.t.file_ensureDir_noopWhenFolderAlreadyExists:{[]
    dir:`:/tmp/qbase_test_file_ensuredir_noop;

    system "mkdir -p ",1_ string dir;

    / Calling it again on an already-existing folder must not error and must leave it in place
    result:.[.file.ensureDir; enlist dir; {[e] `FAILED}];
    existsAfter:.[.type.isFolder; enlist dir; {[e] 0b}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[dir; result];
    .test.assert.true existsAfter;
 };


// -- .file.tree ---------------------------------------------------------------

.t.file_tree_listsAllFilesRecursivelyFullyQualified:{[]
    dir:`:/tmp/qbase_test_file_tree;

    .t.i.buildFileTreeFixture dir;

    actual:.[.file.tree; enlist dir; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    expected:asc ` sv/: dir,/:(`a.txt; `b.txt; `sub`c.txt);
    .test.assert.equals[expected; asc actual];
 };


// -- .file.isCompressed ---------------------------------------------------------

.t.file_isCompressed_falseForUncompressedFile:{[]
    dir:`:/tmp/qbase_test_file_compressed;
    f:` sv dir,`plain.txt;

    system "mkdir -p ",1_ string dir;
    f 0: enlist "not compressed";

    actual:.[.file.isCompressed; enlist f; {[e] `FAILED}];

    system "rm -rf ",1_ string dir;

    .test.assert.false actual;
 };

.t.file_isCompressed_raisesForNonPathArgument:{[]
    .test.assert.raisesLike[.file.isCompressed; enlist "not a path"; "*IllegalArgumentException*"];
 };


// -- .file.replace --------------------------------------------------------------

.t.file_replace_movesSourceOverTarget:{[]
    dir:`:/tmp/qbase_test_file_replace;
    src:` sv dir,`src.txt;
    tgt:` sv dir,`tgt.txt;

    system "mkdir -p ",1_ string dir;
    src 0: enlist "SOURCE_CONTENT";
    tgt 0: enlist "OLD_TARGET_CONTENT";

    .[.file.replace; (src; tgt); {[e] (::)}];

    tgtContent:.[read0; enlist tgt; {[e] enlist "FAILED"}];
    srcStillExists:.[.type.isFile; enlist src; {[e] 1b}];

    system "rm -rf ",1_ string dir;

    .test.assert.equals[enlist "SOURCE_CONTENT"; tgtContent];
    .test.assert.false srcStillExists;
 };

.t.file_replace_raisesForNonPathArguments:{[]
    dir:`:/tmp/qbase_test_file_replace_bad;
    tgt:` sv dir,`tgt.txt;

    system "mkdir -p ",1_ string dir;
    tgt 0: enlist "TARGET";

    .test.assert.raisesLike[.file.replace; ("not a path"; tgt); "*IllegalArgumentException*"];
    .test.assert.raisesLike[.file.replace; (tgt; "not a path"); "*IllegalArgumentException*"];

    system "rm -rf ",1_ string dir;
 };
