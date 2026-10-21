// qbase Tests - time (thin wrappers over the native .z.* date/time primitives)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`time;


.t.time_nowReturnsTimestampCloseToNative:{[]
    .test.assert.true[-12h = type .time.now[]];
    .test.assert.true[1000000000 > abs `long$.time.now[] - .z.p];
 };

.t.time_todayReturnsDateMatchingNative:{[]
    .test.assert.true[-14h = type .time.today[]];
    .test.assert.equals[.z.d; .time.today[]];
 };

.t.time_nowAsTimeReturnsTimeTypeCloseToNative:{[]
    .test.assert.true[-19h = type .time.nowAsTime[]];
    .test.assert.true[1000 > abs `long$.time.nowAsTime[] - .z.t];
 };

.t.time_nowAsTimespanReturnsTimespanCloseToNative:{[]
    .test.assert.true[-16h = type .time.nowAsTimespan[]];
    .test.assert.true[1000000000 > abs `long$.time.nowAsTimespan[] - .z.n];
 };

.t.time_getLocalTimeDifferenceReturnsPlausibleOffset:{[]
    diff:.time.getLocalTimeDifference[];
    .test.assert.true[-19h = type diff];
    / A timezone offset from UTC is always within +/- 14 hours
    .test.assert.true[(abs `long$diff) <= `long$14:00:00.000];
 };
