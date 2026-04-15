# dotflow v2 — professional flow prompt for high-signal shell sessions.
#
# Features:
# - Context line shown only when directory changes
# - Optional focus/context modes via `dfmode`
# - Path compression for deep trees (e.g. ~/S/d/n/l/plugins)
# - Git segment caching for faster prompt rendering
# - Safety cues for root, ssh, and protected branches
# - Slow command timer shown in RPROMPT

setopt prompt_subst
autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null

typeset -g _df_mode="${DOTFLOW_MODE:-context}"
typeset -gi _df_transient=1
typeset -g _df_present="off"
typeset -g _df_last_dir=""
typeset -g _df_cmd_index=0
typeset -g _df_palette="${DOTFLOW_PALETTE:-ocean}"
typeset -g _df_color_user=75
typeset -g _df_color_host=109
typeset -g _df_color_path=220
typeset -g _df_color_meta=244
typeset -g _df_color_rail=110
typeset -g _df_color_ok=150
typeset -g _df_color_dirty=209
typeset -g _df_color_error=203
typeset -g _df_rail_glyph="│"
typeset -g _df_arrow_glyph="❯"
typeset -gF _df_cmd_start=0
typeset -g _df_last_duration=""
typeset -g _df_git_cache_pwd=""
typeset -gF _df_git_cache_time=0
typeset -g _df_git_cache_value=""
typeset -gF _df_git_cache_ttl=2
typeset -g _df_ctx_cache_value=""
typeset -gF _df_ctx_cache_time=0
typeset -gF _df_ctx_cache_ttl=3
typeset -g _df_mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotflow-mode"
typeset -g _df_palette_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotflow-palette"

if [[ -z "${DOTFLOW_MODE:-}" && -f "$_df_mode_file" ]]; then
  typeset _df_saved_mode
  _df_saved_mode="$(<"$_df_mode_file")"
  if [[ "$_df_saved_mode" == "focus" || "$_df_saved_mode" == "context" ]]; then
    _df_mode="$_df_saved_mode"
  fi
fi

if [[ -z "${DOTFLOW_PALETTE:-}" && -f "$_df_palette_file" ]]; then
  typeset _df_saved_palette
  _df_saved_palette="$(<"$_df_palette_file")"
  if [[ "$_df_saved_palette" == "graphite" || "$_df_saved_palette" == "ocean" || "$_df_saved_palette" == "ember" ]]; then
    _df_palette="$_df_saved_palette"
  fi
fi

_df_apply_palette() {
  case "$_df_palette" in
    graphite)
      _df_color_user=252
      _df_color_host=250
      _df_color_path=223
      _df_color_meta=244
      _df_color_rail=246
      _df_color_ok=114
      _df_color_dirty=215
      _df_color_error=203
      ;;
    ember)
      _df_color_user=223
      _df_color_host=215
      _df_color_path=220
      _df_color_meta=245
      _df_color_rail=215
      _df_color_ok=150
      _df_color_dirty=209
      _df_color_error=203
      ;;
    *) # ocean
      _df_palette="ocean"
      _df_color_user=75
      _df_color_host=109
      _df_color_path=220
      _df_color_meta=244
      _df_color_rail=110
      _df_color_ok=150
      _df_color_dirty=209
      _df_color_error=203
      ;;
  esac
}

_df_apply_present() {
  if [[ "$_df_present" == "on" ]]; then
    _df_rail_glyph="┃"
    _df_arrow_glyph="▶"
  else
    _df_rail_glyph="│"
    _df_arrow_glyph="❯"
  fi
}

_df_path_compact() {
  local path="${PWD/#$HOME/~}"
  local -a parts
  local out=""
  local i part

  if [[ "$path" == "/" ]]; then
    print -r -- "/"
    return
  fi

  parts=("${(@s:/:)path}")
  for (( i = 1; i <= ${#parts}; i++ )); do
    part="${parts[i]}"
    [[ -z "$part" ]] && continue

    if (( i < ${#parts} )); then
      if [[ "$part" == "~" ]]; then
        out+="~/"
      else
        out+="${part[1,1]}/"
      fi
    else
      out+="$part"
    fi
  done

  print -r -- "${out:-$path}"
}

_df_git_refresh() {
  local branch indicator branch_color=110
  local now
  now=$EPOCHREALTIME

  if [[ "$PWD" == "$_df_git_cache_pwd" ]] && (( now - _df_git_cache_time < _df_git_cache_ttl )); then
    print -r -- "$_df_git_cache_value"
    return
  fi

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _df_git_cache_pwd="$PWD"
    _df_git_cache_time=$now
    _df_git_cache_value=""
    return
  fi

  branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
  [[ -z "$branch" ]] && return

  if [[ "$branch" == "main" || "$branch" == "master" || "$branch" == "develop" ]]; then
    branch_color=$_df_color_error
  fi

  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    indicator="%F{${_df_color_dirty}}●%f"
  else
    indicator="%F{${_df_color_ok}}●%f"
  fi

  _df_git_cache_pwd="$PWD"
  _df_git_cache_time=$now
  _df_git_cache_value=" %F{${_df_color_meta}}on%f %F{${branch_color}}⎇ ${branch}%f ${indicator}"
  print -r -- "$_df_git_cache_value"
}

_df_context_meta() {
  local now venv ssh_seg kube_seg kube_ctx kube_color=244
  now=$EPOCHREALTIME

  if (( now - _df_ctx_cache_time < _df_ctx_cache_ttl )); then
    print -r -- "$_df_ctx_cache_value"
    return
  fi

  venv="${VIRTUAL_ENV:t}"
  [[ -z "$venv" && -n "${CONDA_DEFAULT_ENV:-}" ]] && venv="$CONDA_DEFAULT_ENV"

  [[ -n "$SSH_CONNECTION" ]] && ssh_seg="%F{${_df_color_error}}ssh%f"

  if command -v kubectl >/dev/null 2>&1; then
    kube_ctx="$(kubectl config current-context 2>/dev/null)"
    if [[ -n "$kube_ctx" ]]; then
      if [[ "$kube_ctx:l" == *prod* || "$kube_ctx:l" == *production* || "$kube_ctx:l" == *live* ]]; then
        kube_color=$_df_color_error
      elif [[ "$kube_ctx" == "docker-desktop" || "$kube_ctx" == "minikube" || "$kube_ctx" == kind-* ]]; then
        kube_ctx=""
      else
        kube_color=$_df_color_meta
      fi
      [[ -n "$kube_ctx" ]] && kube_seg="%F{${kube_color}}k8s:${kube_ctx}%f"
    fi
  fi

  _df_ctx_cache_time=$now
  _df_ctx_cache_value=""

  [[ -n "$venv" ]] && _df_ctx_cache_value+="%F{${_df_color_meta}}py:${venv}%f "
  [[ -n "$ssh_seg" ]] && _df_ctx_cache_value+="${ssh_seg} "
  [[ -n "$kube_seg" ]] && _df_ctx_cache_value+="${kube_seg} "

  _df_ctx_cache_value="${_df_ctx_cache_value%% }"
  print -r -- "$_df_ctx_cache_value"
}

_df_preexec() {
  local last_status=$?
  _df_transient_compact "$1" "$last_status"
  _df_cmd_start=$EPOCHREALTIME
}

_df_transient_compact() {
  local cmd="$1"
  local last_status="${2:-0}"

  (( _df_transient == 0 )) && return
  [[ -z "$cmd" ]] && return
  [[ "$cmd" == *$'\n'* ]] && return

  # Move up to the just-rendered prompt line, clear it, and replace with a compact trace.
  printf '\033[1A\r\033[2K'
  local badge="%F{${_df_color_ok}}OK%f"

  (( last_status != 0 )) && badge="%F{${_df_color_error}}ERR:${last_status}%f"

  print -Pn "%F{${_df_color_meta}}·%f %F{${_df_color_rail}}${_df_cmd_index}%f %F{${_df_color_rail}}${_df_arrow_glyph}%f ${cmd} %F{${_df_color_meta}}[%f${badge}%F{${_df_color_meta}}]%f\n"
}

_df_update_duration() {
  local -F elapsed
  local -F 1 elapsed_fmt

  _df_last_duration=""
  (( _df_cmd_start <= 0 )) && return

  elapsed=$(( EPOCHREALTIME - _df_cmd_start ))
  _df_cmd_start=0

  if (( elapsed >= 1.5 )); then
    elapsed_fmt=$elapsed
    _df_last_duration="%F{244}⏱ ${elapsed_fmt}s%f"
  fi
}

_df_rprompt() {
  local mode_seg=""
  local ctx_seg

  ctx_seg="$(_df_context_meta)"

  if [[ "$_df_mode" == "focus" ]]; then
    mode_seg="%F{${_df_color_meta}}[focus]%f "
  fi

  if [[ -n "$_df_last_duration" ]]; then
    if [[ -n "$ctx_seg" ]]; then
      print -r -- "${mode_seg}${ctx_seg} ${_df_last_duration} %F{${_df_color_meta}}%D{%a %d %b  %H:%M}%f"
    else
      print -r -- "${mode_seg}${_df_last_duration} %F{${_df_color_meta}}%D{%a %d %b  %H:%M}%f"
    fi
  else
    if [[ -n "$ctx_seg" ]]; then
      print -r -- "${mode_seg}${ctx_seg} %F{${_df_color_meta}}%D{%a %d %b  %H:%M}%f"
    else
      print -r -- "${mode_seg}%F{${_df_color_meta}}%D{%a %d %b  %H:%M}%f"
    fi
  fi
}

_df_set_prompt() {
  local user_color=$_df_color_user
  local host_color=$_df_color_host
  local compact_path
  local git_seg
  local terminal_narrow=0

  (( COLUMNS > 0 && COLUMNS < 100 )) && terminal_narrow=1

  if (( terminal_narrow == 1 )); then
    compact_path="${PWD/#$HOME/~}"
  else
    compact_path="$(_df_path_compact)"
  fi

  git_seg="$(_df_git_refresh)"

  (( EUID == 0 )) && user_color=$_df_color_error
  [[ -n "$SSH_CONNECTION" ]] && host_color=$_df_color_error

  if [[ "$_df_mode" == "focus" ]]; then
    if [[ "$PWD" != "$_df_last_dir" ]]; then
      _df_last_dir="$PWD"
      PROMPT="%F{${_df_color_path}}${compact_path}%f${git_seg}
%(?..%F{${_df_color_error}}✖ %? %f)%F{${_df_color_rail}}${_df_rail_glyph}%f %F{${_df_color_rail}}${_df_cmd_index} ${_df_arrow_glyph}%f "
    else
      PROMPT="%(?..%F{${_df_color_error}}✖ %? %f)%F{${_df_color_rail}}${_df_rail_glyph}%f %F{${_df_color_rail}}${_df_cmd_index} ${_df_arrow_glyph}%f "
    fi
    return
  fi

  if [[ "$PWD" != "$_df_last_dir" ]]; then
    _df_last_dir="$PWD"
    if (( terminal_narrow == 1 )); then
      PROMPT="%F{${_df_color_path}}${compact_path}%f${git_seg}
%(?..%F{${_df_color_error}}✖ %? %f)%F{${_df_color_rail}}${_df_rail_glyph}%f %F{${_df_color_rail}}${_df_cmd_index} ${_df_arrow_glyph}%f "
    else
      PROMPT="%F{${user_color}}%n%f%F{${_df_color_meta}}@%f%F{${host_color}}%m%f %F{${_df_color_meta}}·%f %F{${_df_color_path}}${compact_path}%f${git_seg}
%(?..%F{${_df_color_error}}✖ %? %f)%F{${_df_color_rail}}${_df_rail_glyph}%f %F{${_df_color_rail}}${_df_cmd_index} ${_df_arrow_glyph}%f "
    fi
  else
    PROMPT="%(?..%F{${_df_color_error}}✖ %? %f)%F{${_df_color_rail}}${_df_rail_glyph}%f %F{${_df_color_rail}}${_df_cmd_index} ${_df_arrow_glyph}%f "
  fi
}

_df_precmd() {
  _df_apply_palette
  _df_apply_present
  _df_update_duration
  (( _df_cmd_index++ ))
  _df_set_prompt
}

dfindex() {
  case "$1" in
    "")
      echo "dotflow index: $_df_cmd_index"
      ;;
    reset)
      _df_cmd_index=0
      _df_last_dir=""
      ;;
    [0-9]##)
      _df_cmd_index="$1"
      _df_last_dir=""
      ;;
    *)
      echo "Usage: dfindex [reset|<number>]"
      return 1
      ;;
  esac
}

dfmode() {
  case "$1" in
    focus|context)
      _df_mode="$1"
      export DOTFLOW_MODE="$_df_mode"
      _df_last_dir=""
      if [[ "$2" == "--save" ]]; then
        mkdir -p "${_df_mode_file:h}" 2>/dev/null
        print -r -- "$_df_mode" >| "$_df_mode_file"
        echo "dotflow mode saved: $_df_mode"
      fi
      ;;
    "")
      echo "dotflow mode: $_df_mode"
      if [[ -f "$_df_mode_file" ]]; then
        echo "saved default: $(<"$_df_mode_file")"
      fi
      ;;
    *)
      echo "Usage: dfmode [focus|context] [--save]"
      return 1
      ;;
  esac
}

dftransient() {
  case "$1" in
    on)
      _df_transient=1
      ;;
    off)
      _df_transient=0
      ;;
    "")
      if (( _df_transient == 1 )); then
        echo "dotflow transient: on"
      else
        echo "dotflow transient: off"
      fi
      ;;
    *)
      echo "Usage: dftransient [on|off]"
      return 1
      ;;
  esac
}

dfpresent() {
  case "$1" in
    on)
      _df_present="on"
      _df_last_dir=""
      ;;
    off)
      _df_present="off"
      _df_last_dir=""
      ;;
    "")
      echo "dotflow presentation mode: $_df_present"
      ;;
    *)
      echo "Usage: dfpresent [on|off]"
      return 1
      ;;
  esac
}

dfpalette() {
  case "$1" in
    graphite|ocean|ember)
      _df_palette="$1"
      export DOTFLOW_PALETTE="$_df_palette"
      _df_last_dir=""
      if [[ "$2" == "--save" ]]; then
        mkdir -p "${_df_palette_file:h}" 2>/dev/null
        print -r -- "$_df_palette" >| "$_df_palette_file"
        echo "dotflow palette saved: $_df_palette"
      fi
      ;;
    "")
      echo "dotflow palette: $_df_palette"
      if [[ -f "$_df_palette_file" ]]; then
        echo "saved palette: $(<"$_df_palette_file")"
      fi
      ;;
    *)
      echo "Usage: dfpalette [graphite|ocean|ember] [--save]"
      return 1
      ;;
  esac
}

add-zsh-hook preexec _df_preexec
add-zsh-hook precmd _df_precmd

# Override clear so context is restated after the screen is cleared.
clear() {
  command clear
  _df_cmd_index=-1
  _df_last_dir=""
}

RPROMPT='$(_df_rprompt)'
