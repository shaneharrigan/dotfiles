#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--skip-tools] [--target DIR] [package ...]

Bootstraps this dotfiles repo by installing CLI tools and stowing packages.
Defaults:
  target: $HOME
  packages: nvim tmux zsh

Optional overlays:
  nvim-delight tmux-delight zsh-flow zsh-omz-delight

Examples:
  ./scripts/bootstrap.sh
  ./scripts/bootstrap.sh --skip-tools zsh tmux
  ./scripts/bootstrap.sh zsh zsh-flow zsh-omz-delight nvim nvim-delight
  ./scripts/bootstrap.sh --target "$HOME" --dry-run
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_TOOLS=0
PASSTHRU_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --skip-tools)
      SKIP_TOOLS=1
      shift
      ;;
    *)
      PASSTHRU_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "$SKIP_TOOLS" -eq 0 ]]; then
  "$ROOT_DIR/scripts/install-tools.sh"
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed yet. Installing it now..."
  "$ROOT_DIR/scripts/install-tools.sh" stow
fi

"$ROOT_DIR/scripts/stow-dotfiles.sh" "${PASSTHRU_ARGS[@]}"

echo
echo "Bootstrap complete. Reload your shell with: exec zsh"
