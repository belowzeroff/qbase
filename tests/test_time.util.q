// qbase Tests - time.util (date/timestamp utility functions)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: 'time.util.q' has no explicit '.require.lib' call of its own - it is discovered and
// loaded alongside 'time.q' as part of the 'time' library's own file set (require matches any
// file named "time.*.q" as well as "time.q" for the 'time' lib), so loading 'time' is enough to
// make everything below available.
.require.lib`time;


/ 2026.10.19 is a Monday, 2026.10.24 is a Saturday, 2026.10.25 is a Sunday - verified by hand
.t.timeutil_isWeekdayTrueForMonday:{[]
    .test.assert.true[.time.isWeekday 2026.10.19];
 };

.t.timeutil_isWeekdayFalseForSaturday:{[]
    .test.assert.false[.time.isWeekday 2026.10.24];
 };

.t.timeutil_isWeekdayFalseForSunday:{[]
    .test.assert.false[.time.isWeekday 2026.10.25];
 };

.t.timeutil_isWeekdayRaisesOnNonDate:{[]
    .test.assert.raisesLike[.time.isWeekday; enlist 5; "*IllegalArgumentException*"];
 };

.t.timeutil_getDayMatchesIsWeekdayForMonday:{[]
    .test.assert.equals[`mon; .time.getDay 2026.10.19];
 };

.t.timeutil_getDayMatchesIsWeekdayForSaturday:{[]
    .test.assert.equals[`sat; .time.getDay 2026.10.24];
 };

.t.timeutil_getDayMatchesIsWeekdayForSunday:{[]
    .test.assert.equals[`sun; .time.getDay 2026.10.25];
 };

.t.timeutil_roundTimestampToMsRoundsDownSubMsPrecision:{[]
    ts:2026.10.20D12:34:56.123456789;
    .test.assert.equals[2026.10.20D12:34:56.123000000; .time.roundTimestampToMs ts];
 };

.t.timeutil_roundTimestampToMsLeavesMsAlignedUnchanged:{[]
    ts:2026.10.20D12:34:56.123000000;
    .test.assert.equals[ts; .time.roundTimestampToMs ts];
 };

.t.timeutil_roundTimestampToMsLeavesInfiniteUnchanged:{[]
    .test.assert.equals[0Wp; .time.roundTimestampToMs 0Wp];
 };

.t.timeutil_roundTimespanToMsRoundsDownSubMsPrecision:{[]
    tsp:0D12:34:56.123456789;
    .test.assert.equals[0D12:34:56.123000000; .time.roundTimespanToMs tsp];
 };

.t.timeutil_roundTimestampToMsRaisesOnNonTimestampOrTimespan:{[]
    .test.assert.raisesLike[.time.roundTimestampToMs; enlist 5; "*IllegalArgumentException*"];
 };

/ Time-dependent functions - only the output SHAPE is asserted, never an exact value

.t.timeutil_nowForFileNameMatchesExpectedShape:{[]
    s:.time.nowForFileName[];
    / Format: yyyymmdd_hhMMss_SSS -> 8 + 1 + 6 + 1 + 3 = 19 characters, digits and underscores only
    .test.assert.equals[19; count s];
    .test.assert.true[s like "????????_??????_???"];
    .test.assert.false[any s in ".:"];
 };

.t.timeutil_todayForFileNameMatchesExpectedShape:{[]
    s:.time.todayForFileName[];
    .test.assert.equals[8; count s];
    .test.assert.true[all s in "0123456789"];
 };

.t.timeutil_nowAsMsRoundedTimestampIsSaneTimestamp:{[]
    ts:.time.nowAsMsRoundedTimestamp[];
    .test.assert.true[.type.isTimestamp ts];
    .test.assert.true[ts within (2020.01.01D00:00:00.000; 2035.01.01D00:00:00.000)];
 };
