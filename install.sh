#!/usr/bin/env bash
#
# qbase installer.
#
#   curl -sSL https://raw.githubusercontent.com/belowzeroff/qbase/master/install.sh | bash
#
# Environment overrides:
#   QBASE_HOME          install location                         (default: $HOME/.qbase)
#   QBASE_REPO          git repository to clone                  (default: git@github.com:belowzeroff/qbase.git)
#   QBASE_REF           branch or tag to install                 (default: master)
#   QBASE_SRC           install from a local directory instead of cloning (offline / dev)
#   QBASE_LINK_QINIT=1  append a qbase loader line to $QINIT (if $QINIT is set)

set -euo pipefail

QBASE_HOME="${QBASE_HOME:-$HOME/.qbase}"
QBASE_REPO="${QBASE_REPO:-git@github.com:belowzeroff/qbase.git}"
QBASE_REF="${QBASE_REF:-master}"
QBASE_SRC="${QBASE_SRC:-}"

log() { printf '\033[1;34m[qbase]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[qbase]\033[0m %s\n' "$*" >&2; }

install_from_local() {
    log "Installing from local source: $QBASE_SRC -> $QBASE_HOME"
    mkdir -p "$QBASE_HOME"
    ( cd "$QBASE_SRC" && tar --exclude=.git -cf - . ) | ( cd "$QBASE_HOME" && tar -xf - )
}

install_from_git() {
    command -v git >/dev/null 2>&1 || { err "git is required to install qbase"; exit 1; }
    if [ -d "$QBASE_HOME/.git" ]; then
        log "Updating existing install at $QBASE_HOME ($QBASE_REF)"
        git -C "$QBASE_HOME" fetch --depth 1 origin "$QBASE_REF"
        git -C "$QBASE_HOME" checkout -qf "$QBASE_REF"
        git -C "$QBASE_HOME" reset --hard -q FETCH_HEAD
    else
        log "Cloning $QBASE_REPO ($QBASE_REF) into $QBASE_HOME"
        git clone --depth 1 --branch "$QBASE_REF" "$QBASE_REPO" "$QBASE_HOME"
    fi
}

if [ -n "$QBASE_SRC" ]; then
    install_from_local
else
    install_from_git
fi

if [ ! -f "$QBASE_HOME/boot.q" ]; then
    err "Installation incomplete: $QBASE_HOME/boot.q not found"
    exit 1
fi

log "qbase installed at $QBASE_HOME"

if [ -z "${QHOME:-}" ]; then
    log "Note: \$QHOME is not set — install kdb+ (q) to run qbase."
fi

# Optional integration with the q startup file ($QINIT)
if [ "${QBASE_LINK_QINIT:-0}" = "1" ] && [ -n "${QINIT:-}" ]; then
    if ! grep -qF "$QBASE_HOME/boot.q" "$QINIT" 2>/dev/null; then
        log "Adding qbase loader to \$QINIT ($QINIT)"
        printf '\\l %s\n' "$QBASE_HOME/boot.q" >> "$QINIT"
    fi
fi

cat <<EOF

qbase is ready. To start a qbase process:

    q "$QBASE_HOME/boot.q"

Load additional libraries at boot with --load-libs, e.g.:

    q "$QBASE_HOME/boot.q" --load-libs http,ipc

...or at runtime:  .require.lib\`http

EOF
