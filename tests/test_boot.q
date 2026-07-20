// qbase Tests - boot (initialisation sequence)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: These assert on the state produced by a real boot.q run, so the suite
// must be launched via boot.q (see tests/run.sh).


.t.boot_rootsAreSet:{[]
    .test.assert.true[(-11h = type .boot.root`kdbCommon) & -11h = type .boot.root`app];
 };

.t.boot_coreLibsConfigured:{[]
    .test.assert.equals[`log`cargs`ns; .boot.cfg.coreLibs];
 };

.t.boot_coreLibsLoaded:{[]
    loaded:exec lib from .require.loadedLibs;
    .test.assert.true[all .boot.cfg.coreLibs in loaded];
 };

.t.boot_bootModesDefined:{[]
    .test.assert.true[all (`$("load-libs"; "script")) in key .boot.cfg.bootModes];
 };

.t.boot_coreNamespacesExist:{[]
    .test.assert.true[all {0 < count key x} each `.require`.log`.cargs`.ns];
 };
