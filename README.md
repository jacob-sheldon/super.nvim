# super.nvim

Portable dotfiles focused on Neovim + tmux workflow across macOS machines.

## What is included

- `nvim/`: full Neovim config from `~/.config/nvim`
- `tmux/tmux.conf`: tmux config
- `gitconfig`: git user config
- `Brewfile`: required packages
- `bootstrap.sh`: one-command setup on a new Mac

## Quick start on a new Mac

1. Install Xcode Command Line Tools:

```bash
xcode-select --install
```

2. Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Clone and bootstrap:

```bash
git clone git@github.com:jacob-sheldon/super.nvim.git ~/super.nvim
cd ~/super.nvim
./bootstrap.sh
```

## Notes

- Do not sync runtime caches like `~/.local/share/nvim` or `~/.local/state/nvim`.
- `bootstrap.sh` installs `typescript-language-server` through Mason.
- Your tmux/nvim keymaps remain in source files here, so migration is git-driven.
