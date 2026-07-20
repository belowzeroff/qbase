// File Manipulation for HDBs
// Copyright (c) 2021 Jaskirat Rajasansir
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0


/ Wrapper for '.Q.par' to deal with relative paths for a segmented DB configuration in the 'par.txt' file
/  @param hdbRoot (FolderPath) The HDB root to run against
/  @param partVal (Date|Month|Year|Long) The specific partition to lookup with 'par.txt' if present
/  @returns (FolderPath) The expected location of the partition within the HDB
.file.hdb.qPar:{[hdbRoot; partVal]
    if[not .type.isFolder hdbRoot;
        '"IllegalArgumentException";
    ];

    par:.Q.par[hdbRoot; partVal; `];
    strPar:1_ string par;

    if[not "/" = first strPar;
        strPar:string[hdbRoot],"/",strPar;
    ];

    :hsym `$strPar;
 };
