// qbase Tests - log.loggers (basic / color / syslog log line renderers)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: These exercise the '.log.loggers.*' functions directly with a capturing 'fd' function
// instead of a real console/file descriptor, so no actual log output is produced. The formatter
// reference used below ('.log.formatter.default') is the same one '.log.setLogger' binds into
// the active logger by default (see 'logger:get[.log.current`logger][get .log.current`formatter;;]'
// in src/log.q, where '.log.current`formatter' defaults to '.log.cfg.formatters`default') -
// confirmed empirically by calling the loggers directly with it and inspecting the captured output.
// '.log.loggers.json' is already covered by 'tests/test_log.q' ('log_jsonLoggerEmitsValidJson')
// and is intentionally not duplicated here.
.require.lib`log;


.t.loggers.i.captured:"";
.t.loggers.i.capture:{[s] .t.loggers.i.captured:s };


.t.loggers_basicContainsLevelAndMessage:{[]
    .t.loggers.i.captured:"";
    .log.loggers.basic[.log.formatter.default; .t.loggers.i.capture; `INFO; "test message"];

    .test.assert.true[.t.loggers.i.captured like "*INFO*"];
    .test.assert.true[.t.loggers.i.captured like "*test message*"];
 };

.t.loggers_colorContainsMessageAndDiffersFromBasic:{[]
    .t.loggers.i.captured:"";
    .log.loggers.basic[.log.formatter.default; .t.loggers.i.capture; `INFO; "test message"];
    basic:.t.loggers.i.captured;

    .t.loggers.i.captured:"";
    .log.loggers.color[.log.formatter.default; .t.loggers.i.capture; `INFO; "test message"];
    color:.t.loggers.i.captured;

    .test.assert.true[color like "*test message*"];
    .test.assert.notEquals[basic; color];
 };

.t.loggers_syslogStartsWithPriorityPrefixAndContainsMessage:{[]
    .t.loggers.i.captured:"";
    .log.loggers.syslog[.log.formatter.default; .t.loggers.i.capture; `INFO; "test message"];

    expectedPrefix:"<",string[.log.levels[`INFO]`syslog],">";
    .test.assert.true[.t.loggers.i.captured like expectedPrefix,"*"];
    .test.assert.true[.t.loggers.i.captured like "*test message*"];
 };
