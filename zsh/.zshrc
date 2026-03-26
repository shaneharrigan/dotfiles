setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
DIRSTACKSIZE=20
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# History and directory navigation.
HISTSIZE=50000
SAVEHIST=50000
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Make completion less rigid and easier to scan.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Optional tool integrations.
# zoxide learns where you actually work and gives smarter directory jumping via `z`.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# direnv loads project-local environment variables as you enter a directory.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# fzf powers fuzzy history/file pickers; ripgrep keeps the file list fast.
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Prefer modern CLI tools when installed, but keep sensible fallbacks.
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
fi

# SSH agent - start once and reuse across terminal sessions
_ssh_agent_env="$HOME/.ssh/agent.env"
if [ -f "$_ssh_agent_env" ]; then
  . "$_ssh_agent_env" > /dev/null 2>&1
fi
if ! ssh-add -l &>/dev/null; then
  ssh-agent -s | sed '/^echo Agent pid /d' > "$_ssh_agent_env"
  . "$_ssh_agent_env" > /dev/null 2>&1
fi
unset _ssh_agent_env

# Auto-start tmux for interactive shells when not already in a tmux session.
if [[ $- == *i* ]] && command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
  exec tmux new-session -A -s main
fi

# Editor and shell shortcuts
alias vi=nvim
alias v=nvim
alias vim=nvim
alias zr='exec zsh'
alias ztools='$HOME/Sources/dotfiles/scripts/install-tools.sh'
alias h='history 1'
alias j='jobs -l'

# Filesystem
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias path='echo $PATH | tr ":" "\n"'
alias du1='du -h --max-depth=1'
alias dfh='df -h'
alias mkdir='mkdir -pv'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first'
  alias la='eza -a --group-directories-first'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias zc='cd ~/Sources/dotfiles'
alias cdd='cd ~/Sources/dotfiles'

# Git shortcuts
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git pull --rebase'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'
alias glog='git log --oneline --graph --decorate -20'

# Gradle (pairs well with your gw alias)
alias gw=./gradlew
alias gwt='./gradlew test'
alias gwb='./gradlew build'
alias gwc='./gradlew clean'
alias gwr='./gradlew run'

# Tmux quality-of-life
alias t='tmux'
alias ta='tmux attach -t main'
alias ts='tmux new-session -A -s main'
alias tn='tmux new -s main'
alias tls='tmux ls'

# Functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

psg() {
  ps aux | grep -i -- "$1" | grep -v grep
}

groot() {
  cd "$(git rev-parse --show-toplevel)"
}

# Copy args or stdin into the desktop clipboard across Wayland/X11 setups.
clipcopy() {
  if command -v wl-copy >/dev/null 2>&1; then
    if [[ $# -gt 0 ]]; then
      printf '%s' "$*" | wl-copy
    else
      wl-copy
    fi
    return
  fi

  if command -v xclip >/dev/null 2>&1; then
    if [[ $# -gt 0 ]]; then
      printf '%s' "$*" | xclip -selection clipboard
    else
      xclip -selection clipboard
    fi
    return
  fi

  if command -v xsel >/dev/null 2>&1; then
    if [[ $# -gt 0 ]]; then
      printf '%s' "$*" | xsel --clipboard --input
    else
      xsel --clipboard --input
    fi
    return
  fi

  echo "No clipboard tool found. Install wl-copy, xclip, or xsel."
  return 1
}

# Jump to a child directory chosen through fzf; falls back cleanly if tooling is missing.
fcd() {
  local target

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed."
    return 1
  fi

  if command -v fd >/dev/null 2>&1; then
    target="$(fd --type d --hidden --exclude .git . | fzf)"
  else
    target="$(find . -type d -not -path '*/.git/*' | sed 's#^./##' | fzf)"
  fi

  [[ -n "$target" ]] && cd "$target"
}

# Fuzzy-pick a branch and switch to it quickly.
fbr() {
  local branch

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed."
    return 1
  fi

  branch="$(git for-each-ref --sort=-committerdate refs/heads refs/remotes --format='%(refname:short)' | awk '!seen[$0]++' | fzf)"
  [[ -n "$branch" ]] && git checkout "$branch"
}

# Fetch, prune, and rebase your current branch in one step.
gsync() {
  git fetch --prune && git pull --rebase
}

# Undo the last commit while keeping changes staged for a corrected commit.
gundo() {
  git reset --soft HEAD~1
}

# Unpack common archive formats without remembering the exact tool flags.
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "cannot extract: $1" ;;
  esac
}

