// qbase Tests - http (auth header helpers)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`http;


.t.http_bearerHeader:{[]
    .test.assert.equals["Bearer tok123"; .http.auth.bearer "tok123"];
 };

.t.http_bearerAcceptsSymbol:{[]
    .test.assert.equals["Bearer abc"; .http.auth.bearer `abc];
 };

.t.http_basicHeader:{[]
    .test.assert.equals["Basic ",.Q.btoa "user:pass"; .http.auth.basic["user"; "pass"]];
 };


// -- .http.i.dechunk ------------------------------------------------------------

.t.http_dechunkSimpleTwoChunks:{[]
    chunked:"5\r\nhello\r\n7\r\n world!\r\n0\r\n\r\n";
    .test.assert.equals["hello world!"; .http.i.dechunk chunked];
 };

.t.http_dechunkIgnoresChunkExtension:{[]
    / The chunk-size line may have ';'-delimited extensions after the hex size - these must be ignored
    chunked:"5;ext=1\r\nhello\r\n0\r\n\r\n";
    .test.assert.equals["hello"; .http.i.dechunk chunked];
 };

.t.http_dechunkDiscardsTrailerHeaders:{[]
    / Trailer headers after the terminating 0-size chunk (and the final CRLF) must be discarded
    chunked:"5\r\nhello\r\n0\r\nX-Trailer: some-value\r\nX-Other-Trailer: another\r\n\r\n";
    .test.assert.equals["hello"; .http.i.dechunk chunked];
 };

.t.http_dechunkEmptyBody:{[]
    .test.assert.equals[""; .http.i.dechunk "0\r\n\r\n"];
 };

.t.http_dechunkManyChunksGeneralises:{[]
    / Checks the loop logic generalises past 2 chunks
    chunked:"1\r\na\r\n2\r\nbc\r\n3\r\ndef\r\n4\r\nghij\r\n5\r\nklmno\r\n0\r\n\r\n";
    .test.assert.equals["abcdefghijklmno"; .http.i.dechunk chunked];
 };

.t.http_dechunkHexChunkSizeIsCaseInsensitive:{[]
    / Chunk-size hex digits may use upper or lower case
    chunked:"A\r\n0123456789\r\n0\r\n\r\n";
    .test.assert.equals["0123456789"; .http.i.dechunk chunked];
 };


// -- .http.i.parseResponse (Transfer-Encoding: chunked) --------------------------

.t.http_parseResponseDecodesChunkedBody:{[]
    raw:"HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\nContent-Type: text/plain\r\n\r\n7\r\nHello, \r\n8\r\nchunked \r\n6\r\nworld!\r\n0\r\n\r\n";

    response:.http.i.parseResponse raw;

    .test.assert.equals["Hello, chunked world!"; response`body];
    .test.assert.equals[200i; response`statusCode];
    .test.assert.equals[`success; response`statusType];
    .test.assert.equals["OK"; response`statusDetail];
 };

.t.http_parseResponseChunkedHeaderIsCaseInsensitive:{[]
    / Header name matching must be case-insensitive, same as content-type / content-encoding
    raw:"HTTP/1.1 200 OK\r\ntransfer-ENCODING: CHUNKED\r\n\r\n4\r\ntest\r\n0\r\n\r\n";

    response:.http.i.parseResponse raw;

    .test.assert.equals["test"; response`body];
 };
