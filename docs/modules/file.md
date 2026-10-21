# file

Filesystem manipulation helpers on top of kdb+'s `key`/`hcount`/`hopen` primitives and the
[`os`](os.md) library.

```q
.file.ls[folder]              / contents of a folder (alias .file.listFolder)
.file.find[fileRegex; folder] / contents matching a glob pattern
.file.ensureDir[dir]          / create 'dir' if it doesn't already exist
.file.tree[root]              / recursively list all files under 'root'
.file.isCompressed[filePath]  / true if the file is kdb+-compressed
.file.replace[source; target] / delete target (if present) then move source onto it
```

Most functions throw `IllegalArgumentException` if given something that isn't a valid
path type. `.file.find`/`.file.findFilePaths` wrap a plain string `fileRegex` in `*...*`
automatically unless it's already a string. `.file.tree` treats symbolic links as folders,
so a circular symlink will recurse forever.
