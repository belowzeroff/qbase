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
