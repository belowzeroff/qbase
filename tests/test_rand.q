// qbase Tests - rand (random data generation)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`rand;


.t.i.randSchema:([] a:`int$(); b:`float$(); c:`symbol$());

/ Calls a '.rand.dr.*' function (reading real bytes from the OS /dev/random device via 'hopen'),
/ which may not be available in every environment. Accepts EITHER a correctly-typed/shaped
/ result OR a caught error from the 'hopen' call - this only fails the assertion if the call
/ succeeds but returns something of the wrong type/shape
/  @param func (Function) The niladic (or unary, for getBytes) '.rand.dr.*' function to call
/  @param arg () The argument to apply (use '::' for the niladic functions)
/  @param validator (Function) Given the successful result, returns a boolean - true if the shape/type is correct
.t.i.assertDrOrUnavailable:{[func; arg; validator]
    res:@[func; arg; {[e] `QBASE_DR_UNAVAILABLE}];

    if[`QBASE_DR_UNAVAILABLE ~ res;
        :1b;
    ];

    :.test.assert.true[validator res];
 };


.t.rand_generateReturnsRequestedRowsAndSchema:{[]
    res:.rand.generate[.t.i.randSchema; 5];

    .test.assert.equals[5; count res];
    .test.assert.equals[cols .t.i.randSchema; cols res];
    .test.assert.equals[type each flip .t.i.randSchema; type each flip res];
 };

.t.rand_generateRaisesOnNonTableSchema:{[]
    .test.assert.raisesLike[.rand.generate; (`notATable; 5); "*IllegalArgumentException*"];
 };

.t.rand_generateRaisesOnNonWholeNumberRows:{[]
    .test.assert.raisesLike[.rand.generate; (.t.i.randSchema; 1.5); "*IllegalArgumentException*"];
 };

.t.rand_generateRaisesOnZeroRows:{[]
    .test.assert.raisesLike[.rand.generate; (.t.i.randSchema; 0); "*IllegalArgumentException*"];
 };

.t.rand_generateRaisesOnNegativeRows:{[]
    .test.assert.raisesLike[.rand.generate; (.t.i.randSchema; -1); "*IllegalArgumentException*"];
 };

.t.rand_drGetBytesReturnsRequestedLength:{[]
    .t.i.assertDrOrUnavailable[.rand.dr.getBytes; 5; {(4h = type x) & 5 = count x}];
 };

.t.rand_drShortReturnsShort:{[]
    .t.i.assertDrOrUnavailable[.rand.dr.short; (::); {-5h = type x}];
 };

.t.rand_drIntReturnsInt:{[]
    .t.i.assertDrOrUnavailable[.rand.dr.int; (::); {-6h = type x}];
 };

.t.rand_drLongReturnsLong:{[]
    .t.i.assertDrOrUnavailable[.rand.dr.long; (::); {-7h = type x}];
 };

.t.rand_drGuidReturnsGuid:{[]
    .t.i.assertDrOrUnavailable[.rand.dr.guid; (::); {-2h = type x}];
 };
