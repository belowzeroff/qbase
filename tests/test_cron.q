// qbase Tests - cron (job scheduler bookkeeping)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: These tests only exercise the scheduling/bookkeeping functions directly and
// synchronously (adding, cancelling and querying '.cron.jobs') - they never wait on, or
// depend on, a real '.z.ts' timer tick firing.

.require.lib`cron;


/ Dummy, always-present function reference for job registration. Never actually invoked by
/ these tests - only the bookkeeping around it is checked, not real execution
.t.i.cronDummyFunc:{[] :1b};


.t.cron_addRunOnceJob_appearsInJobsTable:{[]
    startTime:.time.now[] + 0D01:00:00;
    jobId:.cron.addRunOnceJob[`.t.i.cronDummyFunc; (::); startTime];
    job:.cron.jobs jobId;

    / '.cron.add' rounds the start time to the nearest millisecond before storing it
    .test.assert.equals[`.t.i.cronDummyFunc; job`func];
    .test.assert.equals[`once; job`runType];
    .test.assert.equals[.time.roundTimestampToMs startTime; job`nextRunTime];

    .cron.cancelJob jobId;
 };

.t.cron_addRepeatForeverJob_appearsInJobsTable:{[]
    startTime:.time.now[] + 0D01:00:00;
    interval:0D00:05:00;
    jobId:.cron.addRepeatForeverJob[`.t.i.cronDummyFunc; (::); startTime; interval];
    job:.cron.jobs jobId;

    .test.assert.equals[`repeat; job`runType];
    .test.assert.equals[interval; job`interval];
    .test.assert.true[.type.isInfinite job`endTime];

    .cron.cancelJob jobId;
 };

.t.cron_cancelJob_setsNextRunTimeInfinite:{[]
    startTime:.time.now[] + 0D01:00:00;
    jobId:.cron.addRunOnceJob[`.t.i.cronDummyFunc; (::); startTime];

    .test.assert.false[.type.isInfinite .cron.jobs[jobId]`nextRunTime];

    .cron.cancelJob jobId;

    .test.assert.true[.type.isInfinite .cron.jobs[jobId]`nextRunTime];
 };

.t.cron_cancelJob_unknownIdRaises:{[]
    .test.assert.raisesLike[.cron.cancelJob; enlist 999999999; "*InvalidCronJobException*"];
 };

/ A job scheduled for 'now' (allowed only when historical start times are permitted) must be
/ immediately identified as due by the same 'nextRunTime <= now' check '.cron.ts' uses - without
/ actually relying on the real system timer to tick
.t.cron_dueJob_identifiedByNextRunTime:{[]
    origMode:.cron.cfg.historicalStartTimes;
    .cron.cfg.historicalStartTimes:`allowed;

    jobId:.cron.addRunOnceJob[`.t.i.cronDummyFunc; (::); .time.now[]];

    .cron.cfg.historicalStartTimes:origMode;

    due:exec id from .cron.jobs where nextRunTime <= .time.now[];
    .test.assert.true[jobId in due];

    .cron.cancelJob jobId;
 };

.t.cron_addJob_invalidRunTypeRaises:{[]
    .test.assert.raisesLike[.cron.add; (`.t.i.cronDummyFunc; (::); `bogusRunType; .time.now[] + 0D01:00:00; 0Np; 0Nn); "*InvalidCronRunTypeException*"];
 };

.t.cron_addJob_missingFunctionRaises:{[]
    .test.assert.raisesLike[.cron.add; (`.t.i.noSuchCronFunc; (::); `once; .time.now[] + 0D01:00:00; 0Np; 0Nn); "*FunctionDoesNotExistFunction*"];
 };

.t.cron_addJob_historicalStartTimeRaisesByDefault:{[]
    .test.assert.equals[`disallowed; .cron.cfg.historicalStartTimes];
    .test.assert.raisesLike[.cron.add; (`.t.i.cronDummyFunc; (::); `once; .time.now[] - 0D01:00:00; 0Np; 0Nn); "*InvalidCronJobTimeException*"];
 };
