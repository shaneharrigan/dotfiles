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
  bat clipboard direnv eza fd fzf go graphviz lazydocker lazysql node plantuml pmd ripgrep spotbugs stow wl-clipboard xclip xsel zoxide
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

have() {
  command -v "$1" >/dev/null 2>&1
}

brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo /home/linuxbrew/.linuxbrew/bin/brew
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo /opt/homebrew/bin/brew
    return
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    echo /usr/local/bin/brew
    return
  fi

  return 1
}

run_brew() {
  local brew

  brew="$(brew_bin)" || {
    echo "Homebrew is not installed or not on PATH." >&2
    return 1
  }

  "$brew" "$@"
}

pick_package_manager() {
  if brew_bin >/dev/null 2>&1; then
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
    brew:go) echo go ;;
    brew:graphviz) echo graphviz ;;
    brew:lazydocker) echo lazydocker ;;
    brew:node) echo node ;;
    brew:plantuml) echo plantuml ;;
    brew:pmd) echo pmd ;;
    brew:ripgrep) echo ripgrep ;;
    brew:spotbugs) echo spotbugs ;;
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
    apt:go) echo golang-go ;;
    apt:graphviz) echo graphviz ;;
    apt:lazydocker)
      echo "Unsupported tool for apt installs: lazydocker" >&2
      echo "Install Homebrew first or install lazydocker manually, then rerun the shell bootstrap." >&2
      exit 1
      ;;
    apt:lazysql)
      echo "Unsupported tool for apt installs: lazysql" >&2
      echo "Install Homebrew first or install lazysql manually, then rerun the shell bootstrap." >&2
      exit 1
      ;;
    apt:node) echo nodejs ;;
    apt:plantuml) echo plantuml ;;
    apt:pmd|apt:spotbugs)
      echo "Unsupported tool for apt installs: $tool" >&2
      echo "Install Homebrew first or install $tool manually, then rerun the shell bootstrap." >&2
      exit 1
      ;;
    apt:ripgrep) echo ripgrep ;;
    brew:stow) echo stow ;;
    apt:stow) echo stow ;;
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

install_lazysql() {
  local manager="$1"
  local gobin="$HOME/.local/bin"
  local go_cmd
  local go_prefix

  if [[ "$manager" != "brew" ]]; then
    echo "lazysql is not managed through $manager in this script." >&2
    echo "Install Homebrew first or install lazysql manually, then rerun the shell bootstrap." >&2
    exit 1
  fi

  if ! have go; then
    echo "Installing Go for lazysql..."
    run_brew install go
  fi

  if have go; then
    go_cmd="$(command -v go)"
  else
    go_prefix="$(run_brew --prefix go)"
    go_cmd="$go_prefix/bin/go"
  fi

  if [[ ! -x "$go_cmd" ]]; then
    echo "Go was installed, but the go executable was not found." >&2
    return 1
  fi

  mkdir -p "$gobin"
  echo "Installing lazysql into $gobin..."
  GOBIN="$gobin" "$go_cmd" install github.com/jorgerojas26/lazysql@latest
}

ensure_fzf_extras() {
  local manager="$1"

  if [[ "$manager" == "brew" ]]; then
    local prefix
    prefix="$(run_brew --prefix fzf 2>/dev/null || true)"
    if [[ -n "$prefix" && -x "$prefix/install" ]]; then
      echo "Running fzf post-install script for key bindings and completion..."
      "$prefix/install" --key-bindings --completion --no-update-rc
    fi
  fi
}

main() {
  local manager
  local explicit_request=0
  local requested_tools=()
  local packages=()
  local custom_tools=()
  local filtered_tools=()
  local tool
  local package

  manager="$(pick_package_manager)"

  if [[ $# -gt 0 ]]; then
    explicit_request=1
    requested_tools=("$@")
  else
    requested_tools=(
      ripgrep
      fzf
      lazydocker
      lazysql
      zoxide
      direnv
      eza
      bat
      fd
      stow
      clipboard
    )
  fi

  if [[ "$manager" == "apt" ]]; then
    for tool in "${requested_tools[@]}"; do
      if [[ "$tool" == "lazydocker" || "$tool" == "lazysql" ]]; then
        if [[ "$explicit_request" -eq 1 ]]; then
          echo "$tool is not managed through apt in this script." >&2
          echo "Install Homebrew first or install $tool manually, then rerun the shell bootstrap." >&2
          exit 1
        fi
        echo "Skipping $tool for apt installs. Install it manually or use Homebrew if you want it managed here."
        continue
      fi
      filtered_tools+=("$tool")
    done
    requested_tools=("${filtered_tools[@]}")
  fi

  for tool in "${requested_tools[@]}"; do
    if [[ "$tool" == "lazysql" ]]; then
      custom_tools+=("$tool")
      continue
    fi
    package="$(package_for "$manager" "$tool")"
    packages+=("$package")
  done

  echo "Using package manager: $manager"

  echo "Installing: ${requested_tools[*]}"

  if [[ "$manager" == "brew" && " ${requested_tools[*]} " == *" clipboard "* ]]; then
    echo "Using xclip for clipboard support on Homebrew."
  fi

  if [[ ${#packages[@]} -gt 0 ]]; then
    if [[ "$manager" == "brew" ]]; then
      run_brew install "${packages[@]}"
    else
      sudo apt-get update
      sudo apt-get install -y "${packages[@]}"
    fi
  fi

  for tool in "${custom_tools[@]}"; do
    case "$tool" in
      lazysql) install_lazysql "$manager" ;;
    esac
  done

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
