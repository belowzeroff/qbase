// qbase Tests - ns (namespace management, protected execution)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0


.t.ns_protectedExecuteRunsFunction:{[]
    .test.assert.equals[2; .ns.protectedExecute[{1+1}; ::]];
 };

.t.ns_protectedExecuteReturnsErrorDictOnMissingFunc:{[]
    / Upstream issue #115 / PR #120/#125: protectedExecute used to raise FunctionDoesNotExistException
    / directly instead of returning the standard error dictionary when the function reference
    / does not exist.
    res:.ns.protectedExecute[`.no.such.func; ::];

    .test.assert.true[99h = type res];
    .test.assert.equals[.ns.const.pExecFailure; res`isError];
 };
