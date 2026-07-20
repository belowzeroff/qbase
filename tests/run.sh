#!/usr/bin/env bash
#
# Run the qbase test suite.
#
# Requires a q binary: set $QBIN to its path, or have 'q' on your PATH.
# $QHOME must point at your kdb+ installation (as usual for q).
#
# Exit code is the number of failing tests (0 = all passed), so this can gate CI.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QBIN="${QBIN:-q}"

exec "$QBIN" "$ROOT/boot.q" < "$ROOT/tests/run.q"
