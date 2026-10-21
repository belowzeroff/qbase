# time.util

Higher-level helpers built on top of [`time`](time.md).

```q
.time.isWeekday[dt]              / true for Mon-Fri
.time.getDay[dt]                 / 3-letter day abbreviation, e.g. `mon
.time.nowForFileName[]           / "yyyymmdd_hhMMss_SSS", file-name safe
.time.todayForFileName[]         / "yyyymmdd"
.time.roundTimestampToMs[x]      / round a Timestamp/Timespan down to millisecond precision
```

`.time.isWeekday` throws `IllegalArgumentException` if passed anything other than a
`Date`. `.time.roundTimestampToMs` (aliased as `.time.roundTimespanToMs`) throws the same
exception for a non-timestamp/timespan input, and passes infinite values through
unchanged. `.time.nowForFileName` zero-pads the millisecond component to 3 digits.

```q
q).time.nowForFileName[]
"20260721_085826_877"
```
