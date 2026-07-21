#!/usr/bin/env bash
#
# Launch the qbase microservice example.
#   PORT=8080 QBIN=q ./run.sh
#
# Requires a licensed kdb+ (q on PATH or $QBIN) and $QHOME set as usual.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QBASE_HOME="${QBASE_HOME:-$(cd "$HERE/../.." && pwd)}"
QBIN="${QBIN:-q}"
PORT="${PORT:-8080}"

exec "$QBIN" "$HERE/service.q" -p "$PORT"
