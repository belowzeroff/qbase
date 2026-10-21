#!/usr/bin/env python3
"""
qbase test fixture - minimal raw-socket HTTP/1.1 server that hand-crafts a
valid 'Transfer-Encoding: chunked' response.

This intentionally does NOT use Python's http.server, which does not make it
easy to hand-write chunk framing (size markers, extensions, trailers) onto
the wire - this script writes the exact bytes itself so the fixture is a
faithful test of chunk decoding, not of a library that already does it.

Usage:
    python3 http_chunked_server_fixture.py <port>

Behaviour:
    - Binds to 127.0.0.1:<port> and accepts exactly ONE connection.
    - Reads (and discards) the incoming HTTP request.
    - Sends back a hand-built chunked HTTP/1.1 200 response with three
      chunks of different sizes, terminated by the standard '0\\r\\n\\r\\n'.
    - Closes the connection and exits.

The decoded body sent is EXPECTED_BODY below - callers (e.g.
http_chunked_smoke.sh) assert against this exact string.
"""
import socket
import sys

EXPECTED_BODY = "The quick brown fox jumps over the lazy dog."

# Split EXPECTED_BODY into three chunks of different, deliberately uneven sizes
CHUNKS = [
    EXPECTED_BODY[0:9],    # "The quick"
    EXPECTED_BODY[9:30],   # " brown fox jumps over"
    EXPECTED_BODY[30:],    # " the lazy dog."
]

assert "".join(CHUNKS) == EXPECTED_BODY


def build_chunked_body(chunks):
    out = b""
    for c in chunks:
        data = c.encode()
        out += f"{len(data):x}\r\n".encode() + data + b"\r\n"
    out += b"0\r\n\r\n"
    return out


def main():
    if len(sys.argv) != 2:
        print("usage: http_chunked_server_fixture.py <port>", file=sys.stderr)
        sys.exit(2)

    port = int(sys.argv[1])

    body = build_chunked_body(CHUNKS)
    headers = (
        "HTTP/1.1 200 OK\r\n"
        "Transfer-Encoding: chunked\r\n"
        "Content-Type: text/plain\r\n"
        "\r\n"
    ).encode()

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", port))
    srv.listen(1)

    # Signal readiness to the caller (e.g. the smoke test script polls stdout/log for this)
    print(f"READY 127.0.0.1:{port}", flush=True)

    conn, _addr = srv.accept()
    try:
        conn.settimeout(5)
        try:
            conn.recv(65536)
        except socket.timeout:
            pass

        conn.sendall(headers + body)
    finally:
        conn.close()
        srv.close()

    print("DONE", flush=True)


if __name__ == "__main__":
    main()
