#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

if ! command -v nix >/dev/null 2>&1 &&
  [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # Determinate Nix is installed, but this shell has not loaded its PATH yet.
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
  exec sudo "$(command -v darwin-rebuild)" switch --flake ~/.dotfiles#mac
fi

if command -v nix >/dev/null 2>&1; then
  NIX_BIN="$(command -v nix)"
  exec sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
    switch --flake ~/.dotfiles#mac
fi

echo "Nix is not installed or is not on PATH. Run ./bootstrap.sh once, then rerun ./rebuild.sh." >&2
exit 1
