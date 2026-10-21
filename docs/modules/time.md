# time

Thin wrappers over the standard `.z.*` date/time primitives, so application code doesn't
call `.z.*` directly and can be re-pointed to another time zone later.

```q
.time.now[]                      / .z.p - current timestamp, nanosecond precision
.time.nowAsTime[]                / .z.t - current time, millisecond precision
.time.nowAsTimespan[]            / .z.n - current time, nanosecond precision
.time.today[]                    / .z.d - current date
.time.getLocalTimeDifference[]   / .z.T - .z.t
```

Times are assumed to be GMT. If a different time zone is needed, override these
definitions (or use the [tz module](tz.md) for explicit conversions).
