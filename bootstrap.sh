#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log() {
  printf '[bootstrap] %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" && "$(readlink "$target")" == "$2" ]]; then
      return 0
    fi
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    log "backup $target -> $backup"
    mv "$target" "$backup"
  fi
}

link_path() {
  local source_path="$1"
  local target_path="$2"
  mkdir -p "$(dirname "$target_path")"
  backup_if_exists "$target_path" "$source_path"
  ln -snf "$source_path" "$target_path"
  log "linked $target_path -> $source_path"
}

if ! have brew; then
  log "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

log "install/update Homebrew packages"
brew bundle --file "$DOTFILES_DIR/Brewfile"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "install oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
link_path "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link_path "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  mkdir -p "$ZSH_CUSTOM_DIR/plugins"
  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
    log "install zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  fi
  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
    log "install zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  fi
else
  log "oh-my-zsh not found, skip plugin install"
fi

if have nvim; then
  log "sync nvim plugins"
  nvim --headless -i NONE '+Lazy! sync' +qa

  log "ensure Mason packages"
  nvim --headless -i NONE '+MasonInstall typescript-language-server' +qa
else
  log "nvim not found, skip plugin/bootstrap"
fi

log "done"
log "optional: create $HOME/.zshrc.local for machine-specific secrets/proxy settings"
