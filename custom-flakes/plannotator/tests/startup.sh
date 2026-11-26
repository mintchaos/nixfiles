#!/usr/bin/env bash
set -euo pipefail

binary="${1:?usage: bash tests/startup.sh /path/to/plannotator}"
export HOME="$(mktemp -d)"
trap 'rm -rf -- "$HOME"' EXIT
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export PLANNOTATOR_DATA_DIR="$HOME/data"
export PLANNOTATOR_UPDATE_CHECK=0
export PLANNOTATOR_AUTO_UPDATE=0

test "$("$binary" --version)" = "plannotator 0.29.4"
"$binary" --help > "$HOME/help"
grep -q 'review' "$HOME/help"

# Nix owns updates: even a stale user preference must not launch install.sh.
if PLANNOTATOR_AUTO_UPDATE=1 "$binary" update > "$HOME/update" 2>&1; then
  echo "Nix-managed update unexpectedly succeeded" >&2
  exit 1
fi
grep -q 'managed by Nix' "$HOME/update"
test ! -e "$HOME/.local/bin/plannotator"
