# npm global binaries (npm v11+ FIX — MUST BE FIRST)
export PATH="$HOME/.npm-global/bin:$PATH"


# NVM / NODE
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"


# BUN
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


# OH MY ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ALIASES
alias cls="clear"
alias ll="ls -lah"
alias ..="cd .."
alias ...="cd ../.."

# Git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"


# CUSTOM PROMPT (FIXED)
autoload -Uz vcs_info
setopt PROMPT_SUBST

zstyle ':vcs_info:git:*' formats '(%b)'
zstyle ':vcs_info:git:*' actionformats '%b|%a'

function precmd() {
  vcs_info

  if [[ "$vcs_info_msg_0_" == "(main)" ]]; then
    GIT_BRANCH_COLOR="%F{#F63049}"     
  elif [[ "$vcs_info_msg_0_" == "(develop)" ]]; then
    GIT_BRANCH_COLOR="%F{#FF6500}"     
  else
    GIT_BRANCH_COLOR="%F{#296374}"      
  fi
}

PROMPT='%F{#305669}%1~%f %F{#3BC1A8}git:%f${GIT_BRANCH_COLOR}${vcs_info_msg_0_}%f%F{#3BC1A8}➤%f '

# valid commands
ZSH_HIGHLIGHT_STYLES[command]='fg=#3BC1A8'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#3BC1A8'

# unknown / wrong commands 
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6500'

# arguments
ZSH_HIGHLIGHT_STYLES[argument]='fg=#ABB2BF'

# paths
ZSH_HIGHLIGHT_STYLES[path]='fg=#61AFEF'

# options like -la
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#E6A23C'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#E6A23C'



# => updated configuration code
# =============================================
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Autosuggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Prompt
setopt PROMPT_SUBST

# Execution time
typeset -g CMD_START_TIME

preexec() {
  CMD_START_TIME=$EPOCHSECONDS
}

get_execution_time() {
  [[ -z "$CMD_START_TIME" ]] && return

  local elapsed=$((EPOCHSECONDS - CMD_START_TIME))

  if (( elapsed >= 3 )); then
    echo "%F{244}⏱ ${elapsed}s%f "
  fi
}

# Git
get_git_branch() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)

  [[ -z "$branch" ]] && return

  local ahead=0
  local behind=0

  if git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
    local counts
    counts=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)

    ahead=$(echo "$counts" | awk '{print $1}')
    behind=$(echo "$counts" | awk '{print $2}')
  fi

  local sync=""

  (( ahead > 0 )) && sync+=" %F{46}↑${ahead}%f"
  (( behind > 0 )) && sync+=" %F{214}↓${behind}%f"

  case "$branch" in
    main|master)
      echo "%F{196} $branch%f${sync}"
      ;;
    develop|development)
      echo "%F{69} $branch%f${sync}"
      ;;
    feature/*)
      echo "%F{75} $branch%f${sync}"
      ;;
    fix/*|bugfix/*|hotfix/*)
      echo "%F{215} $branch%f${sync}"
      ;;
    release/*)
      echo "%F{141} $branch%f${sync}"
      ;;
    *)
      echo "%F{250} $branch%f${sync}"
      ;;
  esac
}

# Prompt
PROMPT='$(get_execution_time)%F{117}📂 %1~%f $(get_git_branch) %F{45}❯%f '

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
