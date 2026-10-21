# file.hdb

A single helper for resolving HDB partition paths that respect `par.txt`.

```q
.file.hdb.qPar[hdbRoot; partVal]  / expected on-disk location of a partition
```

Wraps `.Q.par` to also work correctly for relative paths listed in a segmented database's
`par.txt`. Throws `IllegalArgumentException` if `hdbRoot` is not a folder.
