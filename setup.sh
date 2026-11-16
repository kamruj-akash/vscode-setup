#!/usr/bin/env bash
# =====================================================================
#  One-command macOS dev setup (Homebrew, zsh, Node, Bun, VS Code,
#  extensions, settings, snippets, Claude Code).
#
#  Usage on a fresh Mac:
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kamruj-akash/vscode-setup/main/setup.sh)"
#  Or, from a clone:
#    ./setup.sh
#
#  Safe to re-run: every step skips what is already installed, and
#  existing config files are backed up before being replaced.
# =====================================================================
set -euo pipefail

REPO_URL="https://github.com/kamruj-akash/vscode-setup.git"
REPO_RAW="https://raw.githubusercontent.com/kamruj-akash/vscode-setup/main"
NVM_VERSION="v0.40.3"
STAMP="$(date +%Y%m%d-%H%M%S)"

say()  { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
ok()   { printf "    \033[32m✓\033[0m %s\n" "$*"; }
warn() { printf "    \033[33m!\033[0m %s\n" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

backup() { # backup <file>  -> copies to <file>.backup-<stamp> if it exists
  [[ -e "$1" ]] && cp "$1" "$1.backup-$STAMP" && ok "backed up $1"
  return 0
}

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is for macOS only."; exit 1; }

# ---------- 0. Get the repo files (works for curl|bash too) ----------
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [[ ! -f "$SRC/zshrc" || ! -f "$SRC/settings.json" ]]; then
  say "Fetching setup files"
  SRC="$HOME/.vscode-setup"
  if [[ -d "$SRC/.git" ]]; then git -C "$SRC" pull --ff-only -q
  else git clone -q "$REPO_URL" "$SRC"; fi
  ok "using $SRC"
fi

# ---------- 1. Xcode Command Line Tools ----------
say "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then ok "already installed"
else
  xcode-select --install || true
  echo "    A dialog opened. Finish the install, then re-run this script."
  exit 0
fi

# ---------- 2. Homebrew ----------
say "Homebrew"
if [[ -x /opt/homebrew/bin/brew ]]; then BREW=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then BREW=/usr/local/bin/brew
else
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -x /opt/homebrew/bin/brew ]] && BREW=/opt/homebrew/bin/brew || BREW=/usr/local/bin/brew
fi
eval "$("$BREW" shellenv)"
ok "$(brew --version | head -1)"

# ---------- 3. Brew packages ----------
say "Brew packages"
for f in git zsh-autosuggestions zsh-syntax-highlighting; do
  brew list --formula "$f" >/dev/null 2>&1 && ok "$f (present)" || { brew install "$f"; ok "$f"; }
done
for c in visual-studio-code claude-code font-fira-code-nerd-font; do
  brew list --cask "$c" >/dev/null 2>&1 && ok "$c (present)" || { brew install --cask "$c" || warn "$c failed"; }
done

# ---------- 4. Oh My Zsh ----------
say "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then ok "already installed"
else
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "installed"
fi

# ---------- 5. NVM + Node ----------
say "NVM + Node (LTS)"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | PROFILE=/dev/null bash
fi
set +u; . "$NVM_DIR/nvm.sh"; nvm install --lts >/dev/null; nvm alias default 'lts/*' >/dev/null; set -u
ok "node $(node -v)"
mkdir -p "$HOME/.npm-global/bin"

# ---------- 6. Bun ----------
say "Bun"
if [[ -x "$HOME/.bun/bin/bun" ]]; then ok "already installed"
else curl -fsSL https://bun.sh/install | bash; ok "installed"; fi

# ---------- 7. ~/.zshrc ----------
say "Shell config"
backup "$HOME/.zshrc"
cp "$SRC/zshrc" "$HOME/.zshrc"
ok "~/.zshrc updated"

# ---------- 8. VS Code: settings, snippets, extensions ----------
say "VS Code"
CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
have code && CODE_BIN="$(command -v code)"
USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$USER_DIR/snippets"

backup "$USER_DIR/settings.json"
cp "$SRC/settings.json" "$USER_DIR/settings.json"
ok "settings.json applied"

for lang in javascript javascriptreact typescript typescriptreact; do
  backup "$USER_DIR/snippets/$lang.json"
  cp "$SRC/ConfigureUserSnippets.json" "$USER_DIR/snippets/$lang.json"
done
ok "snippets applied (js/jsx/ts/tsx)"

if [[ -x "$CODE_BIN" ]]; then
  FAILED=()
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    if "$CODE_BIN" --install-extension "$ext" --force >/dev/null 2>&1; then ok "$ext"
    else warn "$ext (not found / failed)"; FAILED+=("$ext"); fi
  done < "$SRC/extensions.list"
  (( ${#FAILED[@]} )) && warn "Failed: ${FAILED[*]}"
else
  warn "VS Code CLI not found; open VS Code once and re-run to install extensions"
fi

say "Done 🎉"
cat <<MSG

  Next steps:
    1. Open a NEW terminal window (or run:  source ~/.zshrc)
    2. Run  claude  to start Claude Code and sign in
    3. Terminal font: set VS Code / Terminal to "FiraCode Nerd Font".
       (settings.json also references a custom "AkashCode" font; install
       it manually if you have the file.)

  Backups of replaced files end with .backup-$STAMP
MSG
