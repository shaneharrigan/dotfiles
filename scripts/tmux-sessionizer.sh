#!/usr/bin/env bash

set -euo pipefail

workspace_roots=(
  "$HOME/Sources"
  "$HOME/src"
  "$HOME/code"
  "$HOME/work"
)

existing_roots=()
for root in "${workspace_roots[@]}"; do
  if [[ -d "$root" ]]; then
    existing_roots+=("$root")
  fi
done

if (( ${#existing_roots[@]} == 0 )); then
  printf 'No workspace roots found.\n' >&2
  exit 1
fi

sanitize_session_name() {
  local value="$1"
  value="${value// /-}"
  value="${value//\//__}"
  value="${value//:/-}"
  value="${value//./-}"
  value="${value//[^A-Za-z0-9_-]/-}"
  value="${value#-}"
  value="${value%-}"
  printf '%s' "${value:-session}"
}

list_projects() {
  local root
  for root in "${existing_roots[@]}"; do
    find "$root" \
      \( -type d \( -name node_modules -o -name .venv -o -name venv -o -name dist -o -name build \) -prune \) -o \
      \( -type d -name .git -print \) -o \
      \( -type f \( \
        -name .git \
        -o -name .projectile \
      \) -print \)
  done | while IFS= read -r marker; do
    dirname "$marker"
  done | awk '!seen[$0]++' | sort
}

project_root_for_dir() {
  local dir="$1"
  local root
  for root in "${existing_roots[@]}"; do
    if [[ "$dir" == "$root"/* || "$dir" == "$root" ]]; then
      printf '%s' "$root"
      return 0
    fi
  done
  return 1
}

session_name_for_dir() {
  local dir="$1"
  local dir_basename root rel_path count project

  dir_basename="$(basename "$dir")"
  count=0
  for project in "${projects[@]}"; do
    if [[ "$(basename "$project")" == "$dir_basename" ]]; then
      ((count += 1))
    fi
  done

  if [[ "$count" == "1" ]]; then
    sanitize_session_name "$dir_basename"
    return 0
  fi

  if root="$(project_root_for_dir "$dir")"; then
    rel_path="${dir#$root/}"
    sanitize_session_name "$rel_path"
    return 0
  fi

  sanitize_session_name "$dir_basename"
}

if [[ "${1:-}" == "--list" ]]; then
  list_projects
  exit 0
fi

projects=()
while IFS= read -r project; do
  [[ -n "$project" ]] && projects+=("$project")
done < <(list_projects)

if (( ${#projects[@]} == 0 )); then
  printf 'No projects found under workspace roots.\n' >&2
  exit 1
fi

if [[ "${1:-}" == "--session-name" ]]; then
  if [[ -z "${2:-}" ]]; then
    printf 'Usage: %s --session-name <directory>\n' "$0" >&2
    exit 1
  fi
  session_name_for_dir "$2"
  exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is required for tmux-sessionizer.\n' >&2
  exit 1
fi

selected_dir="$(
  printf '%s\n' "${projects[@]}" \
    | fzf --prompt='Project session > ' --height=40% --layout=reverse --border
)"

if [[ -z "$selected_dir" ]]; then
  exit 0
fi

session_name="$(session_name_for_dir "$selected_dir")"

if ! tmux has-session -t "$session_name" 2>/dev/null; then
  tmux new-session -d -s "$session_name" -c "$selected_dir"
fi

if [[ -n "${TMUX:-}" ]]; then
  exec tmux switch-client -t "$session_name"
else
  exec tmux attach-session -t "$session_name"
fi
