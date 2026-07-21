// Logging
// Copyright (c) 2015 - 2017 Sport Trades Ltd, 2020 - 2021 Jaskirat Rajasansir
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

/ Basic logger
.log.loggers.basic:{[formatter; fd; lvl; message]
    fd " " sv formatter[5$string lvl; message];
 };

/ Logger with color highlighting of the level based on the configuration in .log.levels
.log.loggers.color:{[formatter; fd; lvl; message]
    lvl:(.log.levels[lvl]`color),(5$string lvl),.log.resetColor;
    fd " " sv formatter[lvl; message];
 };

/ Non-color logger with the additional syslog priority prefix at the start of the log line. This is useful
/ when capturing log output into systemd (via 'systemd-cat').
.log.loggers.syslog:{[formatter; fd; lvl; message]
    syslogLvl:"<",string[.log.levels[lvl]`syslog],">";
    fd " " sv enlist[syslogLvl],formatter[5$string lvl; message];
 };

/ JSON logger
/ NOTE: This logger does not do the slf4j-style parameterised replacement of the message but prints as the supplied list
.log.loggers.json:{[formatter; fd; lvl; message]
    logElems:`date`time`level`processId`user`handle`message!(.time.today[]; .time.nowAsTime[]; lvl; .log.process; `system^.z.u; .z.w; .log.i.formatMessage message);
    logElems,:.log.context;
    fd .j.j logElems;
 };
