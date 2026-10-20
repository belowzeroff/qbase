// qbase Tests - if (interface library)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: '.if.cfg.interfaces' is a GLOBAL keyed table that real libraries (e.g. 'log') have
// already registered real interface bindings into by the time these tests run (via boot.q's
// own '.require.lib' calls). These tests must never call '.if.bindAllInterfaces[]' or touch any
// real library's interfaces - only a throwaway, clearly-fake lib symbol ('qbaseTestIfLib') is
// ever used for '.if.setImplementationsFor' / '.if.bindInterfacesFor' calls here.

.require.lib`if;


.t.i.qbaseTestIf.impl1:{[] :"ok" };
.t.i.qbaseTestIf.impl2:{[] :"different" };
.t.i.qbaseTestIf.notAFunction:42;

/ Runs 'body' (niladic) then always removes the fake lib's rows from '.if.cfg.interfaces',
/ even if an assertion inside 'body' failed - and re-raises that failure afterwards
.t.i.withCleanup:{[body]
    res:.Q.trp[{[f] f[]; (1b; "")}; body; {[err; bt] (0b; err)}];

    delete from `.if.cfg.interfaces where lib = `qbaseTestIfLib;

    if[not res 0;
        'res 1;
    ];
 };


.t.if_setImplementationsForAddsRow:{[]
    .t.i.withCleanup {
        mapping:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl1);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping];

        rows:select from .if.cfg.interfaces where lib = `qbaseTestIfLib;
        .test.assert.equals[1; count rows];
        .test.assert.equals[`.t.i.qbaseTestIf.impl1; first exec implFunc from rows];
     };
 };

.t.if_setImplementationsForRaisesOnBadColumns:{[]
    .t.i.withCleanup {
        badMapping:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; wrongCol:enlist `.t.i.qbaseTestIf.impl1);
        .test.assert.raisesLike[.if.setImplementationsFor; (`qbaseTestIfLib; badMapping); "*InvalidInterfaceMappingException*"];
     };
 };

.t.if_bindInterfacesForBindsSymbolReference:{[]
    .t.i.withCleanup {
        mapping:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl1);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping];
        .if.bindInterfacesFor[`qbaseTestIfLib; 1b];

        .test.assert.equals["ok"; .t.i.qbaseTestIf.if1[]];
     };
 };

.t.if_bindInterfacesForNoOverwriteKeepsExisting:{[]
    .t.i.withCleanup {
        mapping1:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl1);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping1];
        .if.bindInterfacesFor[`qbaseTestIfLib; 1b];

        mapping2:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl2);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping2];
        .if.bindInterfacesFor[`qbaseTestIfLib; 0b];

        .test.assert.equals["ok"; .t.i.qbaseTestIf.if1[]];
     };
 };

.t.if_bindInterfacesForOverwriteReplacesExisting:{[]
    .t.i.withCleanup {
        mapping1:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl1);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping1];
        .if.bindInterfacesFor[`qbaseTestIfLib; 1b];

        mapping2:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `.t.i.qbaseTestIf.impl2);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping2];
        .if.bindInterfacesFor[`qbaseTestIfLib; 1b];

        .test.assert.equals["different"; .t.i.qbaseTestIf.if1[]];
     };
 };

.t.if_bindInterfacesForRaisesOnMissingImpl:{[]
    .t.i.withCleanup {
        mapping:([] ifFunc:enlist `.t.i.qbaseTestIf.if1; implFunc:enlist `);
        .if.setImplementationsFor[`qbaseTestIfLib; mapping];

        .test.assert.raisesLike[.if.bindInterfacesFor; (`qbaseTestIfLib; 1b); "*MissingInterfaceImplementationException*"];
     };
 };

.t.if_bindFunctionRaisesWhenReferenceMissing:{[]
    .test.assert.raisesLike[.if.i.bindFunction; (`.t.i.qbaseTestIf.if1; `.t.i.qbaseTestIf.doesNotExist; 1b); "*ImplementationFunctionDoesNotExistException*"];
 };

.t.if_bindFunctionRaisesWhenReferenceNotAFunction:{[]
    .test.assert.raisesLike[.if.i.bindFunction; (`.t.i.qbaseTestIf.if1; `.t.i.qbaseTestIf.notAFunction; 1b); "*InvalidImplementationFunctionException*"];
 };
