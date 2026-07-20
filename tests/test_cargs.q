// qbase Tests - cargs (command line argument parsing)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`cargs;


.t.cargs_parsesSimpleFlag:{[]
    r:.cargs.i.parse ("-port"; "5000");
    .test.assert.true[`port in key r];
    .test.assert.equals["5000"; r`port];
 };

.t.cargs_stripsDoubleDash:{[]
    r:.cargs.i.parse enlist "--debug";
    .test.assert.true[`debug in key r];
 };

.t.cargs_joinsMultiValueArgs:{[]
    r:.cargs.i.parse ("-hosts"; "hostA"; "hostB");
    .test.assert.equals["hostA hostB"; r`hosts];
 };

.t.cargs_parsesCustomLongArg:{[]
    r:.cargs.i.parse ("--load-libs"; "http,ipc");
    .test.assert.equals["http,ipc"; r[`$"load-libs"]];
 };

.t.cargs_raisesOnNonStringList:{[]
    .test.assert.raisesLike[.cargs.i.parse; enlist `notAStringList; "*IllegalArgument*"];
 };
