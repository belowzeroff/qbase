#!/usr/bin/env bash
#
# Launch the qbase tickerplant subscriber example.
#   TP_HOST=localhost TP_PORT=5010 ./run.sh
#
# Requires a licensed kdb+ (q on PATH or $QBIN) and a running tickerplant.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QBASE_HOME="${QBASE_HOME:-$(cd "$HERE/../.." && pwd)}"
QBIN="${QBIN:-q}"

exec "$QBIN" "$HERE/subscriber.q"
