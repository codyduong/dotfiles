# termux

My environment setup for working on my phone.

## Quick Start

From a fresh Termux install, run:

```bash
pkg install curl -y && curl -fsSL https://raw.githubusercontent.com/codyduong/dotfiles/main/termux/setup/remote.sh | bash
```

Or if you already have the repo cloned:

```bash
bash ~/dotfiles/termux/bootstrap.sh
```

## What's Installed

**Core:** git, curl, wget, openssh, tmux, zsh, neovim, make, clang

**CLI tools:** ripgrep, fd, fzf, bat, git-delta, jq, zoxide, tree

**Languages:** Rust (rustup), Node.js (nvm), Python

**Shell:** Oh My Zsh + antigen plugins

## Key Bindings (tmux)

Matches the wezterm multiplexing workflow:

| Action | Binding |
|---|---|
| Prefix | `Ctrl+Space` |
| Vertical split | `prefix` + `v` |
| Horizontal split | `prefix` + `b` |
| Navigate panes | `prefix` + `h/j/k/l` |
| Zoom pane | `prefix` + `f` |
| Resize panes | `Alt+h/j/k/l` (repeatable) |
| New window | `Ctrl+t` |
| Kill pane | `Ctrl+w` |
| Select window | `Ctrl+1..9` |
| Reload config | `prefix` + `Shift+C` |

## Files

- `bootstrap.sh` — main install script
- `setup/remote.sh` — one-liner remote bootstrap
- `home/.tmux.conf` — tmux config (wezterm-style)
- `home/.zshrc` — zsh config
- `home/.termux/termux.properties` — extra keyboard row + appearance
