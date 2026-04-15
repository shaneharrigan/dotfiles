# Optional flow helpers loaded from ~/.zshrc when stowed.

# Fuzzy jump across your zsh directory stack.
d() {
  local selected index target

  if ! command -v fzf >/dev/null 2>&1; then
    dirs -v
    return 0
  fi

  selected="$(dirs -v | fzf --tac --height=40% --reverse --prompt='dirstack> ')"
  [[ -z "$selected" ]] && return 0

  index="${selected%%[[:space:]]*}"
  [[ -z "$index" ]] && return 1

  # index 0 is $PWD; 1..N are $dirstack[1..N]
  if [[ "$index" -eq 0 ]]; then
    return 0
  fi

  target="${dirstack[$index]}"
  [[ -n "$target" ]] && cd "$target"
}

# Show the recent directory stack with indexes.
dh() {
  dirs -v
}

# Interactive zoxide jump with fzf ranking preview.
zii() {
  local target

  if ! command -v zoxide >/dev/null 2>&1; then
    echo "zoxide is not installed."
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    zi "$@"
    return 0
  fi

  target="$(zoxide query -l | fzf --height=40% --reverse --prompt='zoxide> ')"
  [[ -n "$target" ]] && cd "$target"
}

# Fuzzy-pick a recent command and execute it.
hrun() {
  local selected cmd

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed."
    return 1
  fi

  selected="$(fc -rl 1 | awk '!seen[$0]++' | fzf --height=50% --reverse --prompt='history> ' --preview 'echo {}')"
  [[ -z "$selected" ]] && return 0

  cmd="$(printf '%s\n' "$selected" | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]*//')"
  [[ -z "$cmd" ]] && return 1

  echo "Running: $cmd"
  eval "$cmd"
}

# Measure interactive shell startup time.
zshstartup() {
  local runs="${1:-5}"
  local i

  if ! [[ "$runs" =~ '^[0-9]+$' ]] || [[ "$runs" -lt 1 ]]; then
    echo "Usage: zshstartup [runs]"
    return 1
  fi

  echo "Measuring zsh startup over $runs runs..."
  for (( i = 1; i <= runs; i++ )); do
    /usr/bin/time -f "run $i: %e s" zsh -i -c exit >/dev/null
  done
}
