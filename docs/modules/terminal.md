# terminal

Keeps the kdb+ console's reported size (`system "c"`) in sync with the real terminal
window.

```q
.terminal.setToCurrentSize[]  / re-sync system "c" to the actual terminal size
.terminal.isInteractive[]     / is this an interactive terminal session?
```

On init, if `.terminal.cfg.trackSizeChange` is enabled and the session is interactive,
`.z.pi` is wrapped so every line of input triggers a size re-check (any existing `.z.pi`
handler is preserved and called afterwards). If `.terminal.cfg.setMinWithCommandLineArg`
is enabled, a `-c` command-line argument sets a floor below which the terminal will not be
shrunk.
