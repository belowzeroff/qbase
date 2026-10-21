# event

Lets multiple listener functions be attached to a single kdb+ event (`.z.po`, `.z.pc`,
`.z.wo`, `.z.wc`, process exit) without them overwriting each other.

```q
.event.installHandler[event; bindFunction]   / bind an event to a .z.* handler (once)
.event.addListener[event; listenFunction]    / register a listener for an event
.event.removeListener[event; listenFunction] / unregister a listener
.event.fire[event; args]                     / run every listener for an event
```

On init, `port.open`/`port.close`/`websocket.open`/`websocket.close`/`process.exit` are
bound to their `.z.*` equivalents via `.event.installHandler`, which never overrides an
already-set handler. Listeners run in registration order via `.ns.protectedExecute`, so
one failing listener doesn't stop the others — failures are logged together once all
listeners have run. `.event.addListener` throws `IllegalArgumentException` for an empty
event symbol and `FunctionDoesNotExistException` if the listener reference doesn't exist.
Used internally by [`ipc`](ipc.md) for inbound connection tracking.
