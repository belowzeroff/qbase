// qbase Tests - file.hdb (HDB partition path resolution)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`file;


/ Builds a minimal real HDB root at 'root' with a single date partition 'd' containing a tiny
/ splayed 'trade' table (same idiom as '.t.i.buildCompressPartitionFixture' in test_compress.q)
.t.i.buildHdbFixture:{[root; d]
    system "mkdir -p ",1_ string root;

    `trade set ([] sym:`a`b; price:1.1 2.2; size:10 20);
    .Q.dpft[root; d; `sym; `trade];

    @[`.; `trade; _];
 };


// -- .file.hdb.qPar -------------------------------------------------------------

.t.filehdb_qPar_resolvesRealPartitionFolder:{[]
    root:`:/tmp/qbase_test_filehdb_qpar;
    d:2024.01.01;

    .t.i.buildHdbFixture[root; d];

    actual:.[.file.hdb.qPar; (root; d); {[e] `FAILED}];

    isFolder:.[.type.isFolder; enlist actual; {[e] 0b}];
    matchesDate:actual like "*",string[d],"*";

    system "rm -rf ",1_ string root;

    .test.assert.true isFolder;
    .test.assert.true matchesDate;
 };

.t.filehdb_qPar_raisesForNonExistentHdbRoot:{[]
    .test.assert.raisesLike[.file.hdb.qPar; (`:/tmp/qbase_test_filehdb_qpar_nonexistent; 2024.01.01); "*IllegalArgumentException*"];
 };
