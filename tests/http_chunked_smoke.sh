#!/usr/bin/env bash
#
# Integration smoke test for Transfer-Encoding: chunked decoding in http.q.
#
# Starts the minimal raw-socket fixture server (http_chunked_server_fixture.py),
# makes a REAL .http.get call against it with a licensed q process, and asserts
# the decoded response body matches exactly what the fixture server sent.
#
# This is NOT wired into tests/run.sh (which only runs tests/test_*.q via the
# q test framework) - run it manually:
#
#   QBIN=/path/to/q QHOME=/path/to/qhome bash tests/http_chunked_smoke.sh
#
# Requires: python3, perl (for the alarm-wrapped timeout), a licensed q binary.
#
# Exit code: 0 on success, non-zero on any failure (connection, timeout, mismatch).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QBIN="${QBIN:-q}"
PORT="${PORT:-18080}"

SERVER_LOG="$(mktemp -t http_chunked_server.XXXXXX)"
Q_LOG="$(mktemp -t http_chunked_q.XXXXXX)"
SERVER_PID=""

cleanup() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    rm -f "$SERVER_LOG" "$Q_LOG"
}
trap cleanup EXIT

echo "[smoke] Starting chunked fixture server on 127.0.0.1:$PORT"
python3 "$ROOT/tests/http_chunked_server_fixture.py" "$PORT" > "$SERVER_LOG" 2>&1 &
SERVER_PID=$!

# Wait (bounded) for the server to report readiness, instead of a blind sleep
for _ in $(seq 1 50); do
    if grep -q "^READY" "$SERVER_LOG" 2>/dev/null; then
        break
    fi
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "[smoke] FAIL: fixture server exited before becoming ready" >&2
        cat "$SERVER_LOG" >&2
        exit 1
    fi
    sleep 0.1
done

if ! grep -q "^READY" "$SERVER_LOG" 2>/dev/null; then
    echo "[smoke] FAIL: fixture server did not become ready in time" >&2
    cat "$SERVER_LOG" >&2
    exit 1
fi

echo "[smoke] Server ready, invoking .http.get (10s alarm timeout)"

# Alarm-wrapped q invocation: talks to a server we started, so bound how long we wait
#
# NOTE: every statement below is kept on a single physical line. Piping a script into
# q's stdin (rather than loading it as a file via \l / system "l") does not reliably
# continue multi-line bracketed statements (if[...], $[...] spanning lines) - each
# line is effectively its own top-level statement - so pass/fail is decided here by
# the shell grepping the printed MATCH boolean, not by a q-side if/exit branch.
set +e
perl -e 'alarm 10; exec @ARGV' "$QBIN" "$ROOT/boot.q" > "$Q_LOG" 2>&1 <<EOQ
.require.lib\`http;
response:.http.get["http://127.0.0.1:$PORT/test"; ()!()];
expected:"The quick brown fox jumps over the lazy dog.";
actual:response\`body;
match:expected ~ actual;
-1 "EXPECTED: [",expected,"]";
-1 "ACTUAL:   [",actual,"]";
-1 "MATCH: ",string match;
exit 0;
EOQ
Q_EXIT=$?
set -e

cat "$Q_LOG"

if [ "$Q_EXIT" -ne 0 ] || ! grep -q "MATCH: 1" "$Q_LOG"; then
    echo "[smoke] FAIL (q exit code: $Q_EXIT)" >&2
    exit 1
fi

echo "[smoke] PASS"
exit 0
