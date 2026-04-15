#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: stow-dotfiles.sh [--target DIR] [--dry-run] [package ...]

Stow selected dotfile packages into a target directory.
Defaults:
  target: $HOME
  packages: nvim tmux zsh

Optional overlays:
  nvim-delight tmux-delight zsh-flow zsh-omz-delight
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME"
DRY_RUN=0
PACKAGES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -t|--target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -* )
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      PACKAGES+=("$1")
      shift
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  PACKAGES+=("$@")
fi

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  PACKAGES=(nvim tmux zsh)
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is required but not installed." >&2
  echo "Run: ./scripts/install-tools.sh stow" >&2
  exit 1
fi

for package in "${PACKAGES[@]}"; do
  if [[ ! -d "$ROOT_DIR/$package" ]]; then
    echo "Package directory not found: $package" >&2
    exit 1
  fi
done

STOW_ARGS=(-d "$ROOT_DIR" -t "$TARGET_DIR")
if [[ "$DRY_RUN" -eq 1 ]]; then
  STOW_ARGS+=(--simulate)
fi

for package in "${PACKAGES[@]}"; do
  echo "Stowing package: $package -> $TARGET_DIR"
  stow "${STOW_ARGS[@]}" "$package"
done
