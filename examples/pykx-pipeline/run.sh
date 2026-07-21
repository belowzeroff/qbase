#!/usr/bin/env bash
#
# Launch the qbase PyKX pipeline example.
#   ./run.sh
#
# Requires a licensed kdb+ (q on PATH or $QBIN) and PyKX (pip install pykx).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QBASE_HOME="${QBASE_HOME:-$(cd "$HERE/../.." && pwd)}"
QBIN="${QBIN:-q}"

exec "$QBIN" "$HERE/pipeline.q"
