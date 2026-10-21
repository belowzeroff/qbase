// qbase Tests - tz (timezone conversion)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: 'tz.q' requires real timezone data loaded from 'config/timezone/timezone-config.csv' via
// '.tz.init', which is triggered automatically by '.require.lib`tz`' (confirmed empirically:
// '.tz.timezones' is non-empty - over 70k rows - immediately after the require call below).
// The timezone ID used below is read from the live '.tz.getSupportedTimezones[]' list rather
// than hardcoded. The fixed test timestamp (2026.01.15) is comfortably clear of any DST
// transition for the picked zone: its last configured transition in the CSV is from 1944,
// over 80 years before the test timestamp, so the offset is constant through to 2030.
.require.lib`tz;

if[0 = count .tz.timezones;
    '"TzConfigNotLoadedException - .tz.timezones is empty after .require.lib`tz`";
 ];

/ Picked once at load time from the live supported timezone list - not hardcoded
.t.i.tz.id:first .tz.getSupportedTimezones[];

/ A fixed UTC timestamp in January, comfortably clear of any DST transition for the picked timezone
.t.i.tz.ts:2026.01.15D12:00:00.000000000;


.t.tz_utcToTimezoneAndBackRoundTrips:{[]
    local:.tz.utcToTimezone[.t.i.tz.ts; .t.i.tz.id];
    back:.tz.timezoneToUtc[local; .t.i.tz.id];
    .test.assert.equals[.t.i.tz.ts; back];
 };

.t.tz_timezoneToTimezoneSameZoneIsIdentity:{[]
    res:.tz.timezoneToTimezone[.t.i.tz.ts; .t.i.tz.id; .t.i.tz.id];
    .test.assert.equals[.t.i.tz.ts; res];
 };

.t.tz_utcToTimezoneRaisesOnBadTargetTimezone:{[]
    .test.assert.raisesLike[.tz.utcToTimezone; (.t.i.tz.ts; `NotARealTimezone); "*InvalidTargetTimezoneException*"];
 };

.t.tz_timezoneToUtcRaisesOnBadSourceTimezone:{[]
    .test.assert.raisesLike[.tz.timezoneToUtc; (.t.i.tz.ts; `NotARealTimezone); "*InvalidSourceTimezoneException*"];
 };

.t.tz_getSupportedTimezonesNonEmptyDistinct:{[]
    tzs:.tz.getSupportedTimezones[];
    .test.assert.true[0 < count tzs];
    .test.assert.equals[distinct tzs; tzs];
 };

.t.tz_utcToTimezoneAtomInReturnsAtomOut:{[]
    res:.tz.utcToTimezone[.t.i.tz.ts; .t.i.tz.id];
    .test.assert.equals[.type.isAtom .t.i.tz.ts; .type.isAtom res];
 };

.t.tz_utcToTimezoneListInReturnsListOut:{[]
    tsList:2#.t.i.tz.ts;
    res:.tz.utcToTimezone[tsList; .t.i.tz.id];
    .test.assert.false[.type.isAtom res];
    .test.assert.equals[2; count res];
 };
