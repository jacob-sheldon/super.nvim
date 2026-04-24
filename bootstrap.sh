#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
link_path "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

if have nvim; then
  log "sync nvim plugins"
  nvim --headless -i NONE '+Lazy! sync' +qa

  log "ensure Mason packages"
  nvim --headless -i NONE '+MasonInstall typescript-language-server' +qa
else
  log "nvim not found, skip plugin/bootstrap"
fi

log "done"
