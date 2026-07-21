// Apache Parquet Helpers
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Read / write Apache Parquet via the 'arrowkdb' extension
// (https://github.com/KxSystems/arrowkdb). 'arrowkdb' must be installed and
// loaded. When it is not available, every '.parquet' function raises
// 'ArrowKdbNotAvailableException.

.require.lib each `type`ns;


/ Set to true during '.parquet.init' if arrowkdb is detected in the process
.parquet.cfg.enabled:0b;


.parquet.init:{
    .parquet.cfg.enabled:.parquet.i.isAvailable[];

    $[.parquet.cfg.enabled;
        .log.if.info "Parquet support (arrowkdb) is available";
    / else
        .log.if.warn "arrowkdb is not available; '.parquet' functions are disabled until arrowkdb is loaded"
    ];
 };


/  @returns (Boolean) True if arrowkdb is loaded in the process
.parquet.i.isAvailable:{ .ns.isSet `.arrowkdb.pq.writeParquet };

/ Writes a q table to a Parquet file
/ NOTE: Illustrative wrapper; verify against your installed arrowkdb version
/  @param path (FilePath) Target '.parquet' file
/  @param t (Table) The table to write
/  @throws ArrowKdbNotAvailableException If arrowkdb is not available
.parquet.write:{[path; t] .parquet.i.ensureAvailable[]; .arrowkdb.pq.writeParquetFromTable[path; t; (::)] };

/ Reads a Parquet file into a q table
/ NOTE: Illustrative wrapper; verify against your installed arrowkdb version
/  @param path (FilePath) Source '.parquet' file
/  @throws ArrowKdbNotAvailableException If arrowkdb is not available
.parquet.read:{[path] .parquet.i.ensureAvailable[]; .arrowkdb.pq.readParquetToTable[path; (::)] };


.parquet.i.ensureAvailable:{
    if[not .parquet.cfg.enabled;
        '"ArrowKdbNotAvailableException";
    ];
 };
