#!/usr/bin/env bash

set -euo pipefail

path="${1:-$PWD}"
command_name="${2:-}"
max_len="${3:-42}"
path_helper="${HOME}/Sources/dotfiles/scripts/tmux-path-display.sh"

pretty_command() {
  local cmd="$1"

  cmd="${cmd##*/}"
  case "$cmd" in
    ""|zsh|bash|fish|sh)
      return
      ;;
    lazydocker) printf 'LazyDocker' ;;
    lazygit) printf 'LazyGit' ;;
    nvim) printf 'Neovim' ;;
    vim) printf 'Vim' ;;
    *)
      printf '%s' "$cmd"
      ;;
  esac
}

program="$(pretty_command "$command_name")"
leaf="${path%/}"
leaf="${leaf##*/}"

if [[ -n "${HOME:-}" && "$leaf" == "$HOME" ]]; then
  leaf="~"
fi

if (( max_len <= 14 )) && [[ -n "$program" ]]; then
  printf '%s' "$program"
  exit 0
fi

if (( max_len <= 24 )) && [[ -n "$program" ]]; then
  printf '%s (%s)' "$leaf" "$program"
  exit 0
fi

if (( max_len <= 18 )); then
  printf '%s' "$leaf"
  exit 0
fi

if [[ -x "$path_helper" ]]; then
  path="$("$path_helper" "$path" "$max_len")"
fi

if [[ -n "$program" ]]; then
  printf '%s (%s)' "$path" "$program"
else
  printf '%s' "$path"
fi
