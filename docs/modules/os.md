# os

OS-specific command execution, abstracting Linux/macOS/Windows differences.

```q
.os.run[cmd; paramStr]       / run a named command (from .os.availableCommands) for this OS
.os.availableCommands[]      / commands implemented for the current OS
.os.isProcessAlive[pid]      / true if a process with this PID exists
.os.getTerminalSize[]        / "lines columns" for the current terminal
.os.dereferencePath[path]    / resolve symlinks to the real path
```

`.os.run` throws `UnsupportedOsCommandException` if `cmd` isn't implemented for the
detected OS (`.os.type`, one of `` `l `` / `` `m `` / `` `w ``), and
`IllegalArgumentException` if `paramStr` isn't a string. Commands are looked up by name
from a fixed whitelist per OS (`.os.l.*`, `.os.m.*`, `.os.w.*`) — see the top-level
[Security](../index.md) notes: only feed `cmd` from trusted code, never from untrusted
input. Linux/macOS arguments are escaped by wrapping in single quotes; Windows escaping
(`.os.w.*`) is best-effort and unverified.
