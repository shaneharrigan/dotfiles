#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-tools.sh [tool ...]

Install optional CLI tools used by this dotfiles setup.

Examples:
  ./scripts/install-tools.sh
  ./scripts/install-tools.sh fzf zoxide

Supported tools:
  bat clipboard direnv eza fd fzf ripgrep wl-clipboard xclip xsel zoxide
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

have() {
  command -v "$1" >/dev/null 2>&1
}

pick_package_manager() {
  if have brew; then
    echo brew
    return
  fi

  if have apt-get; then
    echo apt
    return
  fi

  echo "No supported package manager found. Install Homebrew or apt packages manually." >&2
  exit 1
}

package_for() {
  local manager="$1"
  local tool="$2"

  case "$manager:$tool" in
    brew:bat) echo bat ;;
    brew:clipboard) echo xclip ;;
    brew:direnv) echo direnv ;;
    brew:eza) echo eza ;;
    brew:fd) echo fd ;;
    brew:fzf) echo fzf ;;
    brew:ripgrep) echo ripgrep ;;
    brew:wl-clipboard) echo xclip ;;
    brew:xclip) echo xclip ;;
    brew:xsel) echo xsel ;;
    brew:zoxide) echo zoxide ;;
    apt:bat) echo bat ;;
    apt:clipboard) echo wl-clipboard ;;
    apt:direnv) echo direnv ;;
    apt:eza) echo eza ;;
    apt:fd) echo fd-find ;;
    apt:fzf) echo fzf ;;
    apt:ripgrep) echo ripgrep ;;
    apt:wl-clipboard) echo wl-clipboard ;;
    apt:xclip) echo xclip ;;
    apt:xsel) echo xsel ;;
    apt:zoxide) echo zoxide ;;
    *)
      echo "Unsupported tool: $tool" >&2
      exit 1
      ;;
  esac
}

ensure_fzf_extras() {
  local manager="$1"

  if [[ "$manager" == "brew" ]]; then
    local prefix
    prefix="$(brew --prefix fzf 2>/dev/null || true)"
    if [[ -n "$prefix" && -x "$prefix/install" ]]; then
      echo "Running fzf post-install script for key bindings and completion..."
      "$prefix/install" --key-bindings --completion --no-update-rc
    fi
  fi
}

main() {
  local manager
  local requested_tools=()
  local packages=()
  local tool
  local package

  manager="$(pick_package_manager)"

  if [[ $# -gt 0 ]]; then
    requested_tools=("$@")
  else
    requested_tools=(
      ripgrep
      fzf
      zoxide
      direnv
      eza
      bat
      fd
      clipboard
    )
  fi

  for tool in "${requested_tools[@]}"; do
    package="$(package_for "$manager" "$tool")"
    packages+=("$package")
  done

  echo "Using package manager: $manager"
  echo "Installing: ${requested_tools[*]}"

  if [[ "$manager" == "brew" && " ${requested_tools[*]} " == *" clipboard "* ]]; then
    echo "Using xclip for clipboard support on Homebrew."
  fi

  if [[ "$manager" == "brew" ]]; then
    brew install "${packages[@]}"
  else
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
  fi

  if [[ " ${requested_tools[*]} " == *" fzf "* ]]; then
    ensure_fzf_extras "$manager"
  fi

  cat <<'EOF'

Installed tools are only wired into new shells.
Reload with:
  exec zsh
EOF
}

main "$@"