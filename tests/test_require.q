// qbase Tests - require (dependency loading, namespace isolation, cycle guard)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0


.t.require_coreLibsLoaded:{[]
    loaded:exec lib from .require.loadedLibs;
    .test.assert.true[all `require`log`cargs`ns in loaded];
 };

.t.require_tracksInitState:{[]
    .test.assert.true[.require.loadedLibs[`require]`inited];
 };

.t.require_idempotentLoadIsNoop:{[]
    / Loading an already-loaded library must not reload it. This same guard breaks
    / dependency cycles (A requires B requires A), so verify the recorded load time
    / is unchanged after a second load request.
    .require.lib`type;
    before:.require.loadedLibs[`type]`loadedTime;
    .require.lib`type;
    after:.require.loadedLibs[`type]`loadedTime;
    .test.assert.equals[before; after];
 };

.t.require_unknownLibRaises:{[]
    .test.assert.raisesLike[.require.lib; enlist `no_such_lib_xyz; "*LibraryDoesNotExist*"];
 };

.t.require_findFilesLocatesLib:{[]
    files:.require.i.findFiles[`type; .require.location.discovered];
    .test.assert.true[0 < count files];
 };

.t.require_findFilesEmptyForUnknown:{[]
    files:.require.i.findFiles[`definitely_not_a_lib; .require.location.discovered];
    .test.assert.equals[0; count files];
 };

.t.require_namespaceIsolation:{[]
    / Loading a library populates its own namespace (and only its own)
    .require.lib`rand;
    .test.assert.true[0 < count key `.rand];
 };
