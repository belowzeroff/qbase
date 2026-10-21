// qbase Tests - log (logging levels)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`log;


.t.log_levelsPresentInOrder:{[]
    .test.assert.equals[`TRACE`DEBUG`INFO`WARN`ERROR`FATAL; exec level from .log.levels];
 };

.t.log_isLoggingAtInfo:{[]
    orig:.log.current`level;
    .log.current[`level]:`INFO;
    r:.log.isLoggingAt each `TRACE`DEBUG`INFO`WARN`ERROR`FATAL;
    .log.current[`level]:orig;
    .test.assert.equals[001111b; r];
 };

.t.log_isLoggingAtError:{[]
    orig:.log.current`level;
    .log.current[`level]:`ERROR;
    r:.log.isLoggingAt each `TRACE`DEBUG`INFO`WARN`ERROR`FATAL;
    .log.current[`level]:orig;
    .test.assert.equals[000011b; r];
 };

.t.log_setLevelUpdatesCurrent:{[]
    orig:.log.current`level;
    .log.setLevel`WARN;
    lvl:.log.current`level;
    .log.setLevel orig;
    .test.assert.equals[`WARN; lvl];
 };

.t.log_setLevelRaisesOnBadLevel:{[]
    .test.assert.raisesLike[.log.setLevel; enlist `NOT_A_LEVEL; "*IllegalArgument*"];
 };

.t.log_isLoggingAtRaisesOnBadLevel:{[]
    .test.assert.raisesLike[.log.isLoggingAt; enlist `NOPE; "*IllegalArgument*"];
 };

.t.log_contextStringFormatsPairs:{[]
    orig:.log.context;
    .log.setContext `trace_id`user!("abc123"; `alice);
    s:.log.i.contextString[];
    .log.context:orig;
    .test.assert.true[s like "*trace_id=abc123*"];
    .test.assert.true[s like "*user=alice*"];
 };

.t.log_addContextAndClear:{[]
    orig:.log.context;
    .log.clearContext[];
    .log.addContext[`span_id; "s1"];
    added:.log.context`span_id;
    .log.clearContext[];
    cleared:count .log.context;
    .log.context:orig;
    .test.assert.equals["s1"; added];
    .test.assert.equals[0; cleared];
 };

.t.log_contextEmptyStringWhenNoContext:{[]
    orig:.log.context;
    .log.clearContext[];
    s:.log.i.contextString[];
    .log.context:orig;
    .test.assert.equals[""; s];
 };

.t.log_setContextRaisesOnNonDict:{[]
    .test.assert.raisesLike[.log.setContext; enlist `notADict; "*IllegalArgument*"];
 };

.t.log_jsonLoggerEmitsValidJson:{[]
    orig:.log.context;
    .log.clearContext[];
    .log.addContext[`trace_id; "t-1"];
    / fd writes the emitted line into a capture global instead of stdout
    .log.loggers.json[(::); {`.t.i.captured set x}; `INFO; ("user {} logged in"; `alice)];
    .log.context:orig;

    parsed:.j.k .t.i.captured;
    .test.assert.equals["INFO"; parsed`level];
    .test.assert.equals["user alice logged in"; parsed`message];
    .test.assert.equals["t-1"; parsed`trace_id];
 };


// -- Async / batched logging ---------------------------------------------------------------------------------
// NOTE: Per 'src/cron.q', a real '.z.ts' timer tick is never testable in a headless script (it only fires when
// the process is back at its main poll loop). So, exactly like 'tests/test_cron.q' does for cron itself, these
// never wait on or simulate a real timer tick - '.log.i.asyncFlush' is always called directly, and cron
// scheduling is only checked by inspecting '.cron.jobs' (i.e. that it was SCHEDULED, not that it fired).
// Every test below saves and restores every bit of global state it touches ('.log.cfg.async',
// '.log.current`level', '.log.context', '.log.i.asyncSetupDone', '.require.loadedLibs', '.log.i.asyncQueue')
// so no test here leaks state into any later-loaded 'tests/test_*.q' file sharing this q process.

.t.i.asyncCaptured:();
.t.i.asyncCapture:{[s] .t.i.asyncCaptured,:enlist s };


.t.log_async_enqueuesInsteadOfWritingImmediately:{[]
    origAsync:.log.cfg.async;
    origLevel:.log.current`level;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    .log.cfg.async:1b;
    .log.setLevel`INFO;

    .log.info "async queued message";

    queuedAfterCall:count .log.i.asyncQueue;
    lineBeforeFlush:last last .log.i.asyncQueue;

    .log.i.asyncFlush[];

    queuedAfterFlush:count .log.i.asyncQueue;

    .log.cfg.async:origAsync;
    .log.setLevel origLevel;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    / Not written immediately - sitting in the queue, already formatted, after the call returns
    .test.assert.equals[1; queuedAfterCall];
    .test.assert.true[lineBeforeFlush like "*async queued message*"];
    / '.log.i.asyncFlush' actually drains it
    .test.assert.equals[0; queuedAfterFlush];
 };

.t.log_async_multipleLinesSameFdBatchedOnFlush:{[]
    .log.i.asyncQueue:0#.log.i.asyncQueue;
    .t.i.asyncCaptured:();

    .log.i.asyncEnqueue[.t.i.asyncCapture; "line-one"];
    .log.i.asyncEnqueue[.t.i.asyncCapture; "line-two"];

    queuedBeforeFlush:count .log.i.asyncQueue;

    .log.i.asyncFlush[];

    .test.assert.equals[2; queuedBeforeFlush];
    .test.assert.equals[0; count .log.i.asyncQueue];
    / Both lines for the same 'fd' are batched into a SINGLE newline-joined write, not two separate writes
    .test.assert.equals[1; count .t.i.asyncCaptured];
    .test.assert.equals["line-one\nline-two"; first .t.i.asyncCaptured];
 };

.t.log_async_contextCapturedAtEnqueueTimeNotAtFlushTime:{[]
    origAsync:.log.cfg.async;
    origLevel:.log.current`level;
    origContext:.log.context;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    .log.setContext `trace_id`user!("ctx-marker-abc"; `bob);
    .log.cfg.async:1b;
    .log.setLevel`INFO;

    .log.info "context capture test";

    lineRightAfterLog:last last .log.i.asyncQueue;

    / Change the context AFTER the line was queued, BEFORE it is flushed
    .log.clearContext[];

    lineAfterContextCleared:last last .log.i.asyncQueue;

    .log.i.asyncFlush[];

    .log.cfg.async:origAsync;
    .log.setLevel origLevel;
    .log.context:origContext;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    / The queued line was formatted (and so captured the context) at enqueue time
    .test.assert.true[lineRightAfterLog like "*ctx-marker-abc*"];
    / Clearing the context afterwards must NOT retroactively change the already-queued line
    .test.assert.equals[lineRightAfterLog; lineAfterContextCleared];
    / Sanity: the clear really did take effect globally, so the above isn't vacuously true
    .test.assert.equals[0; count .log.context];
 };

.t.log_async_queueOverflowForcesImmediateFlush:{[]
    origMax:.log.cfg.asyncMaxQueueSize;
    .log.i.asyncQueue:0#.log.i.asyncQueue;
    .t.i.asyncCaptured:();

    .log.cfg.asyncMaxQueueSize:3;

    .log.i.asyncEnqueue[.t.i.asyncCapture; "ov-1"];
    .log.i.asyncEnqueue[.t.i.asyncCapture; "ov-2"];
    .log.i.asyncEnqueue[.t.i.asyncCapture; "ov-3"];

    queuedAtLimit:count .log.i.asyncQueue;

    / This 4th line pushes the queue past the (temporarily lowered) max size
    .log.i.asyncEnqueue[.t.i.asyncCapture; "ov-4"];

    queuedAfterOverflow:count .log.i.asyncQueue;

    .log.cfg.asyncMaxQueueSize:origMax;

    .test.assert.equals[3; queuedAtLimit];
    / The overflow forced an immediate flush of everything queued, including the triggering line - not dropped
    .test.assert.equals[0; queuedAfterOverflow];
    .test.assert.equals[1; count .t.i.asyncCaptured];
    .test.assert.equals["ov-1\nov-2\nov-3\nov-4"; first .t.i.asyncCaptured];
 };

.t.log_async_cronNotLoaded_queuesWithoutAutoFlush:{[]
    origAsync:.log.cfg.async;
    origLevel:.log.current`level;
    origLoadedLibs:.require.loadedLibs;
    origSetupDone:.log.i.asyncSetupDone;

    / Simulate 'cron' not being loaded, regardless of whether it actually is in this process
    delete from `.require.loadedLibs where lib=`cron;
    .log.i.asyncSetupDone:0b;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    cronJobsBefore:count .cron.jobs;
    .log.cfg.async:1b;

    result:@[{ .log.setLevel`INFO; .log.info "no cron test"; `NO_ERROR }; ::; { `RAISED }];

    cronJobsAfter:count .cron.jobs;
    queuedCount:count .log.i.asyncQueue;

    .log.cfg.async:origAsync;
    .log.setLevel origLevel;
    .require.loadedLibs:origLoadedLibs;
    .log.i.asyncSetupDone:origSetupDone;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    / Enabling async with 'cron' unavailable must not raise - it just queues
    .test.assert.false[`RAISED~result];
    .test.assert.equals[1; queuedCount];
    / No cron job was added since 'cron' was not seen as loaded
    .test.assert.equals[cronJobsBefore; cronJobsAfter];
 };

.t.log_async_cronLoaded_schedulesAsyncFlushAsCronTask:{[]
    origAsync:.log.cfg.async;
    origLevel:.log.current`level;
    origSetupDone:.log.i.asyncSetupDone;

    / 'cron' is expected to already be loaded in the real test suite by this point (tests/test_cron.q, which
    / loads alphabetically before this file, loads it) - verified empirically. Assert it rather than assume it
    .test.assert.true[`cron in key .require.loadedLibs];

    .log.i.asyncSetupDone:0b;
    .log.cfg.async:1b;
    .log.setLevel`INFO;

    / Confirm '.log.i.asyncFlush' was SCHEDULED as an active cron task - not waiting for, or simulating, any
    / actual timer tick
    scheduled:exec id from .cron.jobs where func=`.log.i.asyncFlush, not nextRunTime=0Wp;

    { .cron.cancelJob x } each scheduled;

    .log.cfg.async:origAsync;
    .log.setLevel origLevel;
    .log.i.asyncSetupDone:origSetupDone;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    .test.assert.true[0 < count scheduled];
 };
