# http

An HTTP/HTTPS client.

```q
.require.lib`http

.http.get["http://example.com/api"; ()!()]
.http.post["http://example.com/api"; .j.j payload; "application/json"; ()!()]
```

Responses are parsed into a dictionary with `statusCode`, `statusType`, `headers` and
`body`. `application/json` responses are auto-parsed with `.j.k`.

## Authentication

```q
headers:enlist[`Authorization]!enlist .http.auth.bearer "my-token"
headers:enlist[`Authorization]!enlist .http.auth.basic["user"; "pass"]
```

Basic auth is also supported inline via the `user:pass@host` URL form.

## TLS & proxy

HTTPS requires OpenSSL to be available to kdb+ (`.util.isTlsAvailable[]`). Proxy
settings are read from `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY`.
