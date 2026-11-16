# =====================================================================
#  ~/.zshrc  —  Akash's setup  (macOS, Apple Silicon + Intel)
# =====================================================================

# ===== HOMEBREW (must be first, so `brew` works everywhere below) =====
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ===== PATH =====
export PATH="$HOME/.npm-global/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ===== NVM =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# ===== OH MY ZSH =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ===== ALIASES =====
alias cls="clear"
alias ll="ls -lah"
alias ..="cd .."
alias ...="cd ../.."

alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# ===== PROMPT =====
setopt PROMPT_SUBST
zmodload zsh/datetime

typeset -g CMD_START_TIME EXEC_TIME_MSG

preexec() {
  CMD_START_TIME=$EPOCHSECONDS
}

precmd() {
  EXEC_TIME_MSG=""
  if [[ -n "$CMD_START_TIME" ]]; then
    local elapsed=$((EPOCHSECONDS - CMD_START_TIME))
    (( elapsed >= 3 )) && EXEC_TIME_MSG="%F{244}⏱ ${elapsed}s%f "
    unset CMD_START_TIME
  fi
}

get_git_branch() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  [[ -z "$branch" ]] && return

  local ahead=0 behind=0 sync=""
  if git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
    read ahead behind <<< "$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)"
  fi
  (( ahead > 0 )) && sync+=" %F{46}↑${ahead}%f"
  (( behind > 0 )) && sync+=" %F{214}↓${behind}%f"

  case "$branch" in
    main|master)             echo "%F{196}⎇ $branch%f${sync}" ;;
    develop|development)     echo "%F{69}⎇ $branch%f${sync}" ;;
    feature/*)               echo "%F{75}⎇ $branch%f${sync}" ;;
    fix/*|bugfix/*|hotfix/*) echo "%F{215}⎇ $branch%f${sync}" ;;
    release/*)               echo "%F{141}⎇ $branch%f${sync}" ;;
    *)                       echo "%F{250}⎇ $branch%f${sync}" ;;
  esac
}

PROMPT='${EXEC_TIME_MSG}%F{117}📂 %1~%f $(get_git_branch) %F{45}❯%f '

# ===== ZSH PLUGINS (installed via Homebrew) =====
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  [ -s "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # Syntax highlighting must be loaded LAST
  [ -s "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#3BC1A8'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#3BC1A8'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6500'
ZSH_HIGHLIGHT_STYLES[argument]='fg=#ABB2BF'
ZSH_HIGHLIGHT_STYLES[path]='fg=#61AFEF'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#E6A23C'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#E6A23C'
