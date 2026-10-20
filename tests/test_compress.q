// qbase Tests - compress (splay/partition compression, column & table filters)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`compress;


/ Builds a tiny real splayed table fixture (sym/price/size) at 'dir' for exercising
/ '.compress.splay' directly
.t.i.buildCompressSplayFixture:{[dir]
    system "mkdir -p ",1_ string dir;
    dir set .Q.en[dir] ([] sym:`a`b`c; price:1.1 2.2 3.3; size:100 200 300);
 };

/ Builds a tiny real date-partitioned HDB fixture with 2 tables (trade/quote) at 'root'
/ for a single partition 'd', for exercising '.compress.partition' directly
.t.i.buildCompressPartitionFixture:{[root; d]
    system "mkdir -p ",1_ string root;

    `trade set ([] sym:`a`b; price:1.1 2.2; size:10 20);
    `quote set ([] sym:`a`b; bid:1.0 2.0; ask:1.2 2.2);

    .Q.dpft[root; d; `sym; `trade];
    .Q.dpft[root; d; `sym; `quote];

    @[`.; `trade`quote; _];
 };


// -- .compress.splay: compressColumns / ignoreColumns (BuaBook/kdb-common#83) ---------------

.t.compress_splay_ignoreColumns_copiesIgnoredCompressesRest:{[]
    srcDir:`:/tmp/qbase_test_compress_splay1;

    .t.i.buildCompressSplayFixture srcDir;

    options:.compress.cfg.compressDefaults;
    options[`dryrun]:1b;
    options[`ignoreColumns]:enlist `price;

    result:.[.compress.splay; (srcDir; `:/tmp/qbase_test_compress_splay1_tgt; `gzip; options); {[e] `FAILED}];

    system "rm -rf /tmp/qbase_test_compress_splay1";

    writeModes:exec column!writeMode from result;
    .test.assert.equals[`copy; writeModes`price];
    .test.assert.equals[`compress; writeModes`sym];
    .test.assert.equals[`compress; writeModes`size];
 };

.t.compress_splay_compressColumns_onlyListedCompressed:{[]
    srcDir:`:/tmp/qbase_test_compress_splay2;

    .t.i.buildCompressSplayFixture srcDir;

    options:.compress.cfg.compressDefaults;
    options[`dryrun]:1b;
    options[`compressColumns]:enlist `price;

    result:.[.compress.splay; (srcDir; `:/tmp/qbase_test_compress_splay2_tgt; `gzip; options); {[e] `FAILED}];

    system "rm -rf /tmp/qbase_test_compress_splay2";

    writeModes:exec column!writeMode from result;
    .test.assert.equals[`compress; writeModes`price];
    .test.assert.equals[`copy; writeModes`sym];
    .test.assert.equals[`copy; writeModes`size];
 };

.t.compress_splay_compressColumnsAndIgnoreColumnsBothSetRaises:{[]
    srcDir:`:/tmp/qbase_test_compress_splay3;

    .t.i.buildCompressSplayFixture srcDir;

    options:.compress.cfg.compressDefaults;
    options[`compressColumns]:enlist `price;
    options[`ignoreColumns]:enlist `size;

    .test.assert.raisesLike[.compress.splay; (srcDir; `:/tmp/qbase_test_compress_splay3_tgt; `gzip; options); "*IllegalArgumentException*"];

    system "rm -rf /tmp/qbase_test_compress_splay3";
 };


// -- .compress.partition: ignoreTables (BuaBook/kdb-common#82) -----------------------------

.t.compress_partition_ignoreTables_excludesTable:{[]
    srcRoot:`:/tmp/qbase_test_compress_hdb;
    tgtRoot:`:/tmp/qbase_test_compress_hdb_tgt;
    d:2024.01.01;

    .t.i.buildCompressPartitionFixture[srcRoot; d];
    system "mkdir -p /tmp/qbase_test_compress_hdb_tgt";

    options:.compress.cfg.compressDefaults;
    options[`dryrun]:1b;
    options[`ignoreTables]:enlist `quote;

    result:.[.compress.partition; (srcRoot; tgtRoot; d; `COMP_ALL; `gzip; options); {[e] `FAILED}];

    system "rm -rf /tmp/qbase_test_compress_hdb /tmp/qbase_test_compress_hdb_tgt";

    .test.assert.equals[enlist `trade; distinct exec table from result];
 };
