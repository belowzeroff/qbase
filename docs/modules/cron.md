# cron

An in-process job scheduler built on kdb+'s system timer (`.z.ts`).

```q
.cron.addRunOnceJob[func; args; startTime]                       / run once
.cron.addRepeatForeverJob[func; args; startTime; interval]        / repeat forever
.cron.addRepeatUntilTimeJob[func; args; startTime; endTime; interval] / repeat until a time
.cron.cancelJob[jobId]                                             / stop a job
.cron.changeMode[mode]                                             / `ticking or `tickless
```

`func` must be a symbol reference to an existing function; jobs run via
`.ns.protectedExecute`, so a failing job is caught and logged (with backtrace if
`.cron.cfg.printBacktraceOnFailure` is set) rather than killing the timer. By default
(`.cron.cfg.historicalStartTimes` = `` `disallowed ``), `.cron.add` throws
`InvalidCronJobTimeException` for a start time in the past; set it to `` `allowed `` or
`` `setAsNow `` to change that behaviour. `tickless` mode only fires the system timer when a
job is actually due, instead of polling every `.cron.cfg.timerInterval` ms. Execution
history is recorded in `.cron.status` (if `.cron.cfg.logStatus` is set; failures are always
recorded) and cleared automatically every midnight.
