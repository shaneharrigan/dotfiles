#!/usr/bin/env bash

set -euo pipefail

path="${1:-$PWD}"
max_len="${2:-48}"

if [[ -n "${HOME:-}" && "$path" == "$HOME"* ]]; then
  path="~${path#$HOME}"
fi

# Fast path when already short enough.
if (( ${#path} <= max_len )); then
  printf '%s' "$path"
  exit 0
fi

IFS='/' read -r -a parts <<< "$path"

# Handle paths like ~/foo/bar or /var/log
prefix=""
start_index=0
if [[ "$path" == ~/* || "$path" == "~" ]]; then
  prefix="~/"
  start_index=1
elif [[ "$path" == /* ]]; then
  prefix="/"
  start_index=1
fi

# Build from tail segments first and keep semantic chunking.
out=""
for (( i=${#parts[@]}-1; i>=start_index; i-- )); do
  segment="${parts[$i]}"
  [[ -z "$segment" ]] && continue

  if [[ -z "$out" ]]; then
    out="$segment"
  else
    out="$segment/$out"
  fi

  candidate="${prefix}.../${out}"
  if (( ${#candidate} > max_len )); then
    # Remove the segment that made it too long and stop.
    if [[ "$out" == */* ]]; then
      out="${out#*/}"
    fi
    break
  fi
done

if [[ -z "$out" ]]; then
  # Hard fallback: show right-most characters.
  printf '...%s' "${path: -$((max_len-3))}"
  exit 0
fi

result="${prefix}.../${out}"
if (( ${#result} > max_len )); then
  printf '...%s' "${result: -$((max_len-3))}"
else
  printf '%s' "$result"
fi
