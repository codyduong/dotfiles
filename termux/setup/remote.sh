#!/data/data/com.termux/files/usr/bin/bash
set -e

# Remote bootstrap for Termux
# Usage (run from a fresh Termux install):
#   curl -fsSL https://raw.githubusercontent.com/codyduong/dotfiles/main/termux/setup/remote.sh | bash
#
# Or if curl isn't installed yet:
#   pkg install curl -y && curl -fsSL https://raw.githubusercontent.com/codyduong/dotfiles/main/termux/setup/remote.sh | bash

REPO="https://github.com/codyduong/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

printf "\033[1;34m[info]\033[0m  Termux dotfiles remote bootstrap\n"

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
  printf "\033[1;34m[info]\033[0m  Installing git ...\n"
  pkg update -y
  pkg install -y git
fi

# Clone or update dotfiles
if [ -d "$DOTFILES_DIR/.git" ]; then
  printf "\033[1;33m[skip]\033[0m  Dotfiles repo already exists, pulling latest ...\n"
  cd "$DOTFILES_DIR" && git pull
else
  printf "\033[1;34m[info]\033[0m  Cloning dotfiles ...\n"
  git clone "$REPO" "$DOTFILES_DIR"
fi

# Run the main bootstrap
printf "\033[1;34m[info]\033[0m  Running bootstrap ...\n"
bash "$DOTFILES_DIR/termux/bootstrap.sh"
