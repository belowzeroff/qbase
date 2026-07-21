// PyKX Integration
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Thin, safe wrappers around PyKX (https://code.kx.com/pykx/). PyKX must be
// installed and its q interface ('pykx.q') loaded into the process. When PyKX is
// not available, every '.py' function raises 'PyKxNotAvailableException so callers
// fail fast with a clear message instead of a cryptic error.

.require.lib each `type`ns;


/ Set to true during '.py.init' if PyKX is detected in the process
.py.cfg.enabled:0b;


.py.init:{
    .py.cfg.enabled:.py.i.isAvailable[];

    $[.py.cfg.enabled;
        .log.if.info "PyKX integration is available";
    / else
        .log.if.warn "PyKX is not available in this process; '.py' functions are disabled until 'pykx.q' is loaded"
    ];
 };


/  @returns (Boolean) True if the PyKX q interface is loaded in the process
.py.i.isAvailable:{ .ns.isSet `.pykx.eval };

/ Evaluates the specified Python code via PyKX
/  @param code (String) Python code to evaluate
/  @throws PyKxNotAvailableException If PyKX is not available
.py.eval:{[code] .py.i.ensureAvailable[]; .pykx.eval code };

/ Imports a Python module via PyKX
/  @param module (Symbol|String) The module to import
/  @throws PyKxNotAvailableException If PyKX is not available
.py.import:{[module] .py.i.ensureAvailable[]; .pykx.import module };

/ Converts a PyKX / foreign object to a native q value
/  @throws PyKxNotAvailableException If PyKX is not available
.py.toq:{[x] .py.i.ensureAvailable[]; .pykx.toq x };

/ Converts a q table to a Pandas DataFrame (returned as a PyKX object)
/ NOTE: Illustrative wrapper; verify against your installed PyKX version
/  @throws PyKxNotAvailableException If PyKX is not available
.py.toPandas:{[t] .py.i.ensureAvailable[]; .pykx.eval["lambda t: t.pd()"; <] t };

/ Converts a q table to a PyArrow Table (returned as a PyKX object)
/ NOTE: Illustrative wrapper; verify against your installed PyKX version
/  @throws PyKxNotAvailableException If PyKX is not available
.py.toArrow:{[t] .py.i.ensureAvailable[]; .pykx.eval["lambda t: t.pa()"; <] t };


.py.i.ensureAvailable:{
    if[not .py.cfg.enabled;
        '"PyKxNotAvailableException";
    ];
 };
