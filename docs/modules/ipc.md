# ipc

Connection management and one-shot queries on top of `hopen`, with inbound/outbound
connection tracking.

```q
.ipc.connect[hostPort]                  / connect with the default timeout
.ipc.connectWithTimeout[hostPort; ms]   / connect with an explicit timeout (null = default)
.ipc.oneShotWithTimeout[hostPort; ms; query] / open, query, and let kdb+ close it
.ipc.getHandlesFor[hostPort]            / outbound handles currently open to a target
.ipc.disconnect[h]                      / close a handle and update tracking tables
```

Connection attempts throw `ConnectionFailedException` on failure and
`IllegalArgumentException` for a malformed host/port or timeout. Outbound connections are
tracked in `.ipc.outbound`; inbound connections (via the [`event`](event.md) library) are
tracked in `.ipc.inbound` if `.ipc.cfg.enableInboundConnTracking` is set. If
`.ipc.cfg.forceUnixDomainSocketsForLocalhost` is enabled on a supporting OS, connections to
`localhost`/`127.0.0.1`/the local host's own address are transparently rerouted over Unix
Domain Sockets. Passwords are masked in logs unless `.ipc.cfg.logPasswordsDuringConnect` is
explicitly enabled.
