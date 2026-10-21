# http.status

A lookup table of English descriptions for HTTP status codes, as defined by
[httpstatuses.com](https://httpstatuses.com/).

```q
.http.status[200]   / "OK"
.http.status[404]   / "Not Found"
.http.status[500]   / "Internal Server Error"
```

`.http.status` is a plain `int`-keyed dictionary; look up any standard code (100-599) to
get its description. Used internally by [`http`](http.md) to populate the `statusType`
field of parsed responses.
