// qbase Tests - so (shared object function manager)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`so;


// -- .so.findSharedObject: OS-standard default path fallback (BuaBook/kdb-common#48) --------

/ Finds a file placed under a (temporarily overridden) default shared object path when the
/ configured env var path has nothing matching. Writing into the real default paths
/ (/usr/lib, /usr/local/lib, ...) requires permissions tests may not have, so this uses '/tmp'
/ as a TEST-ONLY stand-in default path rather than the real OS-standard locations
.t.so_findSharedObject_fallsBackToDefaultPaths:{[]
    origDefaults:.os.defaultSharedObjectPaths;
    testDir:`:/tmp/qbase_test_so_default;
    soPath:` sv testDir,`qbase_test_so_dummy.so;
    soName:"qbase_test_so_dummy.so";

    system "mkdir -p /tmp/qbase_test_so_default";
    soPath 0: enlist "dummy";

    / Test-only override of the resolved (not configured) default paths - restored in the
    / guard below regardless of whether the assertion passes
    .os.defaultSharedObjectPaths,:testDir;

    result:@[.so.findSharedObject; soName; {[e] `FIND_FAILED}];

    .os.defaultSharedObjectPaths:origDefaults;
    hdel soPath;
    system "rmdir /tmp/qbase_test_so_default";

    .test.assert.equals[soPath; result];
 };

/ When neither the env var path nor the default paths have a match, the existing "no matching
/ paths found" warning still fires and empty symbol is still returned
.t.so_findSharedObject_noMatchAnywhereReturnsEmptySymbol:{[]
    .test.assert.equals[`; .so.findSharedObject "qbase_test_so_does_not_exist_anywhere.so"];
 };
