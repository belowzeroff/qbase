// Logging Library
// Copyright (c) 2015 - 2020 Sport Trades Ltd, 2020 - 2021 Jaskirat Rajasansir
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Documentation: https://github.com/BuaBook/kdb-common/wiki/log.q

.require.lib each `util`type`time`cargs`convert`ns;


/ Functions to determine which logger to use. The dictionary key is a symbol reference to the logger function if the
/ value function is true.
/ NOTE: .log.loggers.basic should always be last so it is the fallback if all others are not available
.log.cfg.loggers:()!();
.log.cfg.loggers[`.log.loggers.color]: { (not ""~getenv`KDB_COLORS) | `logColors in key .cargs.get[] };
.log.cfg.loggers[`.log.loggers.syslog]:{ (not ""~getenv`KDB_LOG_SYSLOG) | `logSyslog in key .cargs.get[] };
.log.cfg.loggers[`.log.loggers.json]:  { (not ""~getenv`KDB_LOG_JSON) | `logJson in key .cargs.get[] };
.log.cfg.loggers[`.log.loggers.basic]: { 1b };

/ The formatting functions that take the logging level and the raw message and provide an output ready for printing by the logger.
/ NOTE: Any custom formatter must also support the slf4j-style parameterised logging
/ NOTE 2: The 'pattern' formatter is used when a logging format pattern (in '.log.cfg.format') has been specified
.log.cfg.formatters:()!();
.log.cfg.formatters[`default]:`.log.formatter.default;
.log.cfg.formatters[`pattern]:`.log.formatter.pattern;

/ The available patterns for logging
/ NOTE: "l" and "m" cannot be modified - these will always be the log level and the message respectively
.log.cfg.patterns:(`char$())!();
.log.cfg.patterns[" "]:(::);
.log.cfg.patterns["d"]:`.time.today;
.log.cfg.patterns["t"]:`.time.nowAsTime;
.log.cfg.patterns["P"]:`.time.now;
.log.cfg.patterns["n"]:`.time.nowAsTimespan;
.log.cfg.patterns["l"]:(::);
.log.cfg.patterns["p"]:`.log.process;
.log.cfg.patterns["u"]:{ `system ^ .z.u };
.log.cfg.patterns["h"]:`.z.w;
.log.cfg.patterns["H"]:`.z.h;
.log.cfg.patterns["m"]:(::);
.log.cfg.patterns["T"]:`.log.patterns.callLineTrace;

/ Custom logging format. Each logging pattern must be prefixed with "%" and all elements will be space separated. If this is
/ an empty string, the logging library will use the (faster) default logging
.log.cfg.format:"";

/ The optional logging pattern to use ONLY when the library is initialised and process is in 'debug mode' (i.e. -e 1).
/ If you don't want the library to change to the pattern-based logger (on library init), ensure this is an empty string
/ before the library is initialised
.log.cfg.enhancedDebugPattern:"%d %t %l %p %u %h %T %m";

/ If true, log lines are NOT written synchronously/immediately. Instead they are formatted straight away (so
/ '.log.context' is captured as it was AT THE TIME OF THE LOG CALL) but the actual write to the destination is
/ queued in memory and performed later, in a batch, by '.log.i.asyncFlush' - either on a 'cron' timer (if the
/ 'cron' library happens to be loaded - see '.log.i.setupAsync'), on process exit, when the queue overflows
/ '.log.cfg.asyncMaxQueueSize', or on demand by calling '.log.i.asyncFlush' directly.
/ NOTE: Default is false so every existing, synchronous logging behaviour is completely unchanged unless a
/ caller explicitly opts in. Call '.log.setLevel' (or '.log.setLogger') after changing this for it to take effect
/  @see .log.setLevel
/  @see .log.i.asyncFlush
.log.cfg.async:0b;

/ The interval, in milliseconds, at which '.log.i.asyncFlush' is automatically scheduled via 'cron' (if loaded)
/ when '.log.cfg.async' is enabled
/  @see .log.i.setupAsync
.log.cfg.asyncFlushIntervalMs:1000;

/ The maximum number of entries allowed to build up in the async log queue before a synchronous flush of
/ everything currently queued is forced (a safety valve against unbounded memory growth if nothing has
/ flushed the queue for a while). No lines are ever dropped
/  @see .log.i.asyncEnqueue
.log.cfg.asyncMaxQueueSize:10000;


/ The maximum level to log at. The logging order is TRACE, DEBUG, INFO, WARN, ERROR, FATAL.
.log.current:(`symbol$())!`symbol$();
.log.current[`level]:    `INFO;
.log.current[`logger]:   `;
.log.current[`formatter]:`;

/ Constant string to reset the color back to default after logging some color
.log.resetColor:"\033[0m";

/ Supported log levels and their related configuration. The order of the table implies the logging order (.e.g a log
/ level of ERROR will log ERROR and FATAL only). The information stored in this table:
/  - fd: The file descriptor to output that log level to
/  - syslog: The equivalent syslog log priority (for use with systemd logging). See 'man syslog'
/  - color: The colors to use for each log level. Empty string means no coloring
/ of ERROR will log ERROR and FATAL)
.log.levels:`level xkey flip `level`fd`syslog`color!"SII*"$\:();
.log.levels[`TRACE]:(-1i; 7i; "");
.log.levels[`DEBUG]:(-1i; 7i; "");
.log.levels[`INFO]: (-1i; 6i; "");
.log.levels[`WARN]: (-1i; 4i; "\033[1;33m");
.log.levels[`ERROR]:(-2i; 3i; "\033[1;31m");
.log.levels[`FATAL]:(-2i; 2i; "\033[4;31m");

/ Process identification
/ NOTE: If this is set prior to the library being initialised, it will not be overwritten during '.log.init'
.log.process:"";

/ Contextual fields automatically appended to every log line and included in JSON logs (e.g. trace_id, span_id, user).
/ Empty by default. Manage with '.log.setContext' / '.log.addContext' / '.log.clearContext'.
.log.context:(`symbol$())!();

/ The parsed custom logging format (from '.log.cfg.format'). This is only populated if '.log.cfg.format' is non-empty
/  @see .log.i.parsePattern
.log.pattern:()!();

/ The in-memory queue of pending async log lines, populated by '.log.i.asyncEnqueue' when '.log.cfg.async' is
/ enabled. Each row is already fully formatted and ready to be written as-is to 'fd' - batched per 'fd' and
/ drained by '.log.i.asyncFlush'
/  @see .log.cfg.async
/  @see .log.i.asyncEnqueue
/  @see .log.i.asyncFlush
.log.i.asyncQueue:([] fd:(); line:());

/ Scratch variable used by '.log.i.asyncLogAndQueue' to capture the line a real '.log.loggers.*' function would
/ have written to 'fd', without actually performing that write
/  @see .log.i.asyncLogAndQueue
/  @see .log.i.asyncCapture
.log.i.asyncCaptured:"";

/ True once '.log.i.setupAsync' has wired up automatic flushing (cron job and/or '.z.exit' hook) for this
/ process. Prevents scheduling duplicate cron jobs or wrapping '.z.exit' more than once if '.log.setLevel' is
/ called repeatedly while '.log.cfg.async' is enabled
/  @see .log.i.setupAsync
.log.i.asyncSetupDone:0b;

/ When call line tracing is enabled, this list of strings can be used to remove common prefixes from the file paths. By default, if this is
/ empty when the library is initialised, it will be defaulted to '.require.location.root'
.log.sourcePathExcludePrefixes:();


.log.init:{
    if[.util.inDebugMode[];
        .log.current[`level]:`DEBUG;

        if[(0 < count .log.cfg.enhancedDebugPattern) & 0 = count .log.process;
            .log.cfg.format:.log.cfg.enhancedDebugPattern;
        ];
    ];

    if[0 = count .log.process;
        .log.process:"pid-",string .z.i;
    ];

    if[0 = count .log.sourcePathExcludePrefixes;
        .log.sourcePathExcludePrefixes,:enlist 1_ string .require.location.root;
    ];

    / setLogger calls setLevel
    .log.setLogger[];
 };


/ Sets the current logger based on the result of the functions defined in .log.cfg.loggers. The first function in the
/ dictionary will be used as the current logger
/  @see .log.cfg.loggers
/  @see .log.current.logger
/  @see .log.current.formatter
/  @see .log.cfg.formatters
/  @see .log.setLevel
.log.setLogger:{
    logger:first where .log.cfg.loggers@\:(::);

    .log.current[`logger]:logger;
    .log.current[`formatter]:.log.cfg.formatters`default;

    if[0 < count .log.cfg.format;
        .log.i.parsePattern[];
        .log.current[`formatter]:.log.cfg.formatters`pattern;
    ];

    .log.setLevel .log.current`level;
 };

/ Configures the logging functions based on the specified level. Any levels below the new level will
/ be set to the identity function
/  @param newLevel (Symbol) The new level to log from
/  @see .log.levels
/  @see .log.cfg.async
.log.setLevel:{[newLevel]
    if[not newLevel in key .log.levels;
        '"IllegalArgumentException";
    ];

    logLevel:key[.log.levels]?newLevel;

    enabled:0!logLevel _ .log.levels;
    disabled:0!logLevel # .log.levels;

    logger:get[.log.current`logger][get .log.current`formatter;;];

    / When async logging is enabled, bind a queueing wrapper around the real 'logger' projection instead of
    / the real logger directly - the wrapper still invokes the exact same (basic/color/syslog/json) logger
    / style already selected above, so async logging works together with whichever logger style is active,
    / rather than replacing it
    if[.log.cfg.async;
        logger:.log.i.asyncLogAndQueue[logger;;;];
        .log.i.setupAsync[];
    ];

    @[`.log; lower enabled`level ; :; logger ./: flip (0!enabled)`fd`level];
    @[`.log; lower disabled`level; :; count[disabled]#(::)];

    .log.current[`level]:newLevel;

    .log.i.setInterfaceImplementations[];

    -1 "\nLogging enabled ","[ ",(" ] [ " sv ": " sv/: flip (@[;0;upper]@/:; ::)@' string (key; value) @\: .log.current)," ]\n";
 };

/ Provides a way to know which log levels are currently being logged. For example, if the log level is currently INFO
/ .log.isLoggingAt will return true for all of INFO, WARN, ERROR, FATAL and false for DEBUG, TRACE.
/  @param level (Symbol) The logging level to check is currently being logged
/  @returns (Boolean) True if the specified level is currently being logged by this library. False otherwise
.log.isLoggingAt:{[level]
    if[not level in key .log.levels;
        '"IllegalArgumentException";
    ];

    :(<=). key[.log.levels]?/: .log.current[`level],level;
 };


/ Default string log formatter with slf4j-style parameterised formatting
/  @returns (StringList) List of log elements in string format
/  @see http://www.slf4j.org/faq.html#logging_performance
.log.formatter.default:{[lvl; message]
    message:.log.i.formatMessage message;

    elems:(.time.today[]; .time.nowAsTime[]; lvl; .log.process; `system^.z.u; .z.w; message);
    elems:@[elems; where not .type.isString each elems; string];

    if[0 < count .log.context;
        elems,:enlist .log.i.contextString[];
    ];

    :elems;
 };

/ Pattern-based string log formatter with slf4j-style parameterised formatting
/  @returns (StringList) List of log elements in string format
.log.formatter.pattern:{[lvl; message]
    if[0h = type message;
        message:"" sv ("{}" vs first message),'(.type.ensureString each 1_ message),enlist "";
    ];

    patterns:.log.pattern,"lm"!(lvl; message);
    patterns:@[patterns; where .type.isSymbol each patterns;      get];
    patterns:@[patterns; where .type.isFunction each patterns;    @[;::]];
    patterns:@[patterns; where not .type.isString each patterns;  string];

    patStrs:value patterns;
    patStrs@:where not ""~/:patStrs;

    :patStrs;
 };


/ Formats a raw log message: if it is a parameterised (slf4j-style) list, substitute "{}" with the supplied arguments
/  @param message (String|List) The raw message
/  @returns (String) The formatted message string
.log.i.formatMessage:{[message]
    if[0h = type message;
        message:"" sv ("{}" vs first message),'(.type.ensureString each 1_ message),enlist "";
    ];
    :message;
 };

/  @returns (String) The current '.log.context' rendered as "[ k=v k2=v2 ]", or empty string if no context is set
.log.i.contextString:{
    if[0 = count .log.context;
        :"";
    ];
    pairs:{ string[x],"=",.type.ensureString y }'[key .log.context; value .log.context];
    :"[ ",(" " sv pairs)," ]";
 };


/ Replaces the entire logging context
/  @param ctx (Dict) Symbol-keyed dictionary of contextual fields (e.g. `trace_id`span_id`user!...)
/  @throws IllegalArgumentException If 'ctx' is not a dictionary
.log.setContext:{[ctx]
    if[not .type.isDict ctx;
        '"IllegalArgumentException";
    ];
    .log.context:ctx;
 };

/ Adds or updates a single contextual field
/  @param field (Symbol) The context field name
/  @param val () The context field value
.log.addContext:{[field; val]
    .log.context[field]:val;
 };

/ Clears all logging context
.log.clearContext:{
    .log.context:(`symbol$())!();
 };


/ Provides function line tracing to where the log line was executed (outside of the 'log' library).
/ It logs in the following formating: 'source-file:function(function-line-number):log-line-number'.
/ NOTE: Not all elements of the call line trace will be available in all situations (e.g. locked code)
/ If the function name is suffixed with an '@' it means an anonymous function within the specified function name. The log
/ line number is then relative to that
.log.patterns.callLineTrace:{
    rawBacktrace:.Q.btx .Q.Ll `;

    / Append the intra-function character position to the other backtrace info
    backtrace:(,).' rawBacktrace@\:1 2;
    backtrace@:where .type.isString each first each backtrace;
    backtrace@:where not (first each backtrace) like ".log.*";

    if[0 = count backtrace;
        :"";
    ];

    backtrace:first backtrace;

    file:.util.findAndReplace[backtrace 1; .log.sourcePathExcludePrefixes; count[.log.sourcePathExcludePrefixes]#enlist "."];
    func:backtrace 0;
    funcLine:backtrace 2;
    lineNum:first where last[backtrace] < sums count each "\n" vs backtrace 3;

    location:enlist "[";
    location,:$[0 < count file; file,":"; ""];
    location,:$[0 < count func; func; "anon"];
    location,:$[not -1 = funcLine; "(",string[funcLine],")"; ""];
    location,:$[not null lineNum; ":",string lineNum; ""];
    location,:"]";

    :location;
 };


/ Sets the interface functions for other qbase component and libraries if the interface 'if' library is defined
/ in the current process
/  @see .require.loadedLibs
/  @see .if.setImplementationsFor
/  @see .if.bindInterfacesFor
.log.i.setInterfaceImplementations:{
    if[not `if in key .require.loadedLibs;
        :(::);
    ];

    allLevels:lower exec level from .log.levels;

    ifFuncs:` sv/: `.log`if,/:allLevels;
    implFuncs:` sv/:`.log,/:allLevels;

    ifTable:flip `ifFunc`implFunc!(ifFuncs; implFuncs);

    .if.setImplementationsFor[`log; ifTable];
    .if.bindInterfacesFor[`log; 1b];
 };

/ If a log pattern is supplied (via '.log.cfg.format'), attempt to parse it and ensure that all the patterns are valid
/  @throws InvalidLogPatternException If any of the patterns specified are not configured in '.log.cfg.patterns'
.log.i.parsePattern:{
    if[0 = count .log.cfg.format;
        :(::);
    ];

    patterns:.log.cfg.format 1 + where "%" = .log.cfg.format;

    if[not all patterns in key .log.cfg.patterns;
        '"InvalidLogPatternException";
    ];

    .log.pattern:patterns#.log.cfg.patterns;
 };


/ ---------------------------------------------------------------------------------------------------------------
/ Async / batched logging
/ ---------------------------------------------------------------------------------------------------------------

/ Used as a stand-in 'fd' when a wrapped logger is invoked by '.log.i.asyncLogAndQueue' so the line it would
/ have written can be captured instead of actually written
/  @see .log.i.asyncLogAndQueue
/  @see .log.i.asyncCaptured
.log.i.asyncCapture:{[line]
    .log.i.asyncCaptured:line;
 };

/ The queueing replacement for the real, bound logger function (missing only 'fd', 'lvl' and 'message' - same
/ shape as the real, unwrapped 'logger' projection in '.log.setLevel') used when '.log.cfg.async' is enabled.
/ It invokes the real logger (whichever '.log.loggers.*' style is currently configured) with '.log.i.asyncCapture'
/ standing in for 'fd', so the exact line that would have been written is computed and captured right now -
/ meaning '.log.context' (and any other state the formatter/logger reads) is captured AS OF THIS CALL, not as
/ of whenever the queue is eventually flushed. Only the write to the real 'fd' is deferred
/  @param logger (Function) The real logger projection with only 'formatter' bound (missing fd, lvl and message)
/  @param fd (Int) The real destination this log level would write to
/  @param lvl (Symbol) The log level being logged at
/  @param message () The raw log message (string, or slf4j-style parameterised list)
/  @see .log.setLevel
/  @see .log.i.asyncEnqueue
.log.i.asyncLogAndQueue:{[logger; fd; lvl; message]
    .log.i.asyncCaptured:"";

    logger[.log.i.asyncCapture; lvl; message];

    .log.i.asyncEnqueue[fd; .log.i.asyncCaptured];
 };

/ Adds an already-formatted log line to the async queue, ready to be written to 'fd' later by '.log.i.asyncFlush'.
/ If the queue has grown beyond '.log.cfg.asyncMaxQueueSize' (meaning nothing has flushed it for a while), this
/ forces an immediate, synchronous flush of everything currently queued - including the line just added - rather
/ than growing the queue unbounded or dropping any line
/  @param fd (Int) The destination to eventually write 'line' to
/  @param line (String) The fully formatted log line, ready to be written to 'fd' as-is
/  @see .log.cfg.asyncMaxQueueSize
/  @see .log.i.asyncFlush
.log.i.asyncEnqueue:{[fd; line]
    `.log.i.asyncQueue insert (fd; line);

    if[count[.log.i.asyncQueue] > .log.cfg.asyncMaxQueueSize;
        .log.if.warn "Async log queue exceeded maximum size. Forcing an immediate flush [ Max Queue Size: ",string[.log.cfg.asyncMaxQueueSize]," ]";
        .log.i.asyncFlush[];
    ];
 };

/ Drains the entire current async log queue, actually writing every queued line to its real destination. Lines
/ are grouped and batched per 'fd' (newline-joined into a single write per destination) to minimise the number
/ of synchronous I/O calls - which is the whole point of queueing in the first place. Safe to call when the
/ queue is empty (no-op) and safe to call at any time, including manually, to force a flush (e.g. before a
/ planned shutdown)
/  @see .log.i.asyncQueue
/  @see .log.i.asyncEnqueue
.log.i.asyncFlush:{[]
    if[0 = count .log.i.asyncQueue;
        :(::);
    ];

    queued:.log.i.asyncQueue;
    .log.i.asyncQueue:0#.log.i.asyncQueue;

    grouped:group queued`fd;

    { [queued; fd; idxs] fd "\n" sv queued[`line] idxs }[queued] ./: flip (key grouped; value grouped);
 };

/ Ensures queued async log lines are eventually flushed without any further action from the caller:
/  * If the 'cron' library happens to be loaded, schedules '.log.i.asyncFlush' as a recurring cron job, running
/    every '.log.cfg.asyncFlushIntervalMs'
/  * If 'cron' is NOT loaded, async logging still works (lines are queued, nothing is lost) but nothing flushes
/    them automatically - the caller must either load 'cron' before enabling async logging, or call
/    '.log.i.asyncFlush[]' manually/periodically themselves. This is logged clearly below
/  * Either way, wraps '.z.exit' (preserving any handler already set, rather than overriding it - mirroring
/    the same pattern used by '.terminal.i.enableSizeTracking' for '.z.pi') so any still-queued lines are
/    flushed on normal process exit rather than silently lost
/ Idempotent: safe to call every time '.log.setLevel' runs with '.log.cfg.async' enabled - will not schedule a
/ duplicate cron job or wrap '.z.exit' more than once
/  @see .log.cfg.async
/  @see .log.cfg.asyncFlushIntervalMs
/  @see .log.i.asyncSetupDone
.log.i.setupAsync:{[]
    if[.log.i.asyncSetupDone;
        :(::);
    ];

    if[`cron in key .require.loadedLibs;
        .cron.addRepeatForeverJob[`.log.i.asyncFlush; (::); .time.now[] + .convert.msToTimespan .log.cfg.asyncFlushIntervalMs; .convert.msToTimespan .log.cfg.asyncFlushIntervalMs];
        .log.if.info "Async log flush scheduled via cron [ Interval: ",string[.log.cfg.asyncFlushIntervalMs]," ms ]";
    ];

    if[not `cron in key .require.loadedLibs;
        .log.if.warn "Async logging enabled but the 'cron' library is not loaded - queued log lines will NOT be flushed automatically. Load 'cron' before enabling async logging, or call '.log.i.asyncFlush[]' manually/periodically";
    ];

    dotZdotExit:(::);

    if[.ns.isSet `.z.exit;
        .log.if.debug "Overloading existing .z.exit handler for async log flushing";
        dotZdotExit:.z.exit;
    ];

    set[`.z.exit;] .log.i.wrapZExit[dotZdotExit;];

    .log.i.asyncSetupDone:1b;
 };

/ The '.z.exit' handler installed (or wrapped around any pre-existing handler) when async logging is set up -
/ flushes any remaining queued log lines before continuing on to the original handler (if there was one)
/  @param origZExit (Function|Generic Null) The '.z.exit' handler that was already set before async logging was
/         enabled, or generic null (::) if none was set
/  @param ec (Long) The process exit code, as supplied by kdb to '.z.exit'
/  @see .log.i.setupAsync
.log.i.wrapZExit:{[origZExit; ec]
    .log.i.asyncFlush[];

    if[not origZExit ~ (::);
        origZExit ec;
    ];
 };
