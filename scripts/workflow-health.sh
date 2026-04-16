#!/usr/bin/env bash

set -euo pipefail

TOOLS=(
  git
  zsh
  tmux
  nvim
  rg
  fzf
  fd
  lazydocker
  bat
  eza
  zoxide
  direnv
  stow
)

missing=0

echo "Workflow health check"
echo "====================="

for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "[ok]   %s\n" "$tool"
  else
    printf "[miss] %s\n" "$tool"
    missing=1
  fi
done

echo
if [[ "$missing" -eq 0 ]]; then
  echo "All recommended tools are installed."
else
  echo "Some tools are missing. Install with: ./scripts/install-tools.sh"
fi
