# wsc

A minimal WebSocket client, built on the [`http`](http.md) library's URL/request
machinery.

```q
.wsc.connect[url]  / open a WebSocket connection, returning a handle
```

`url` must use the `ws://` or `wss://` scheme (`InvalidWebSocketUrlException` otherwise),
and `.z.ws` must already be set to handle inbound WebSocket messages
(`ZWsHandlerNotSetException` otherwise) before connecting. A failed connection throws
`WebSocketConnectionFailedException`. If `.wsc.cfg.logToIpc` is enabled (the default), the
[`ipc`](ipc.md) library is loaded on init and the new connection is also recorded in
`.ipc.outbound`.
