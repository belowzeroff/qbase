# compress

Compresses (or copies) splayed tables and whole HDB partitions, and reports existing
compression stats.

```q
.compress.getSplayStats[splayPath]                              / per-column compression stats for a splay
.compress.getPartitionStats[hdbRoot; partVal]                   / stats for every table in a partition
.compress.splay[srcSplayPath; tgtSplayPath; compressType; opts] / compress/copy a splay
.compress.partition[srcRoot; tgtRoot; partVal; tbls; compressType; opts]  / compress a whole partition
```

`compressType` can be a symbol into `.compress.defaults` (`none`, `qipc`, `gzip`,
`snappy`, `lz4hc`, `zstd`) or a raw 3-element algorithm/logicalBlockSize/zipLevel list.
`opts` merges onto `.compress.cfg.compressDefaults`, which controls `recompress`,
`inplace`, `parallel`, `dryrun`, `gc`, and column/table include-lists. By default already-
compressed columns are copied rather than recompressed, and compression of the splay's
columns is parallelised unless `parallel:0b` is set. `.compress.splay` throws
`InplaceCompressionForbiddenException` if source and target paths match but `inplace`
isn't set, and `TargetAlreadyExistsException` if a non-inplace target already has content.
