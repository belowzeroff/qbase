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
