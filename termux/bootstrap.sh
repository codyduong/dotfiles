#!/data/data/com.termux/files/usr/bin/bash
set -e

# Termux Bootstrap Script
# Run this after cloning the dotfiles repo, or via the remote one-liner.

DOTFILES_DIR="$HOME/dotfiles"
TERMUX_HOME="$DOTFILES_DIR/termux/home"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[ok]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[1;33m[skip]\033[0m  %s\n" "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

install_pkg() {
  for p in "$@"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      warn "$p already installed"
    else
      info "Installing $p ..."
      pkg install -y "$p"
    fi
  done
}

# ---------------------------------------------------------------------------
# 0. Termux basics
# ---------------------------------------------------------------------------

info "Updating package repos ..."
pkg update -y && pkg upgrade -y

# Grant storage access (creates ~/storage symlinks)
if [ ! -d "$HOME/storage" ]; then
  info "Requesting storage permission ..."
  termux-setup-storage
fi

# ---------------------------------------------------------------------------
# 1. Core packages
# ---------------------------------------------------------------------------

info "Installing core packages ..."
install_pkg \
  git \
  curl \
  wget \
  openssh \
  tmux \
  zsh \
  neovim \
  python \
  make \
  clang \
  binutils

# ---------------------------------------------------------------------------
# 2. CLI tools (matches your Windows dev-tool selection where available)
# ---------------------------------------------------------------------------

info "Installing CLI tools ..."
install_pkg \
  ripgrep \
  fd \
  fzf \
  bat \
  jq \
  tree \
  less \
  diffutils \
  patch \
  tar \
  gzip \
  unzip

# delta (git-delta) - available in Termux repos
install_pkg git-delta

# zoxide (smart cd)
install_pkg zoxide

# ---------------------------------------------------------------------------
# 3. Rust (via rustup)
# ---------------------------------------------------------------------------

export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

if has rustup; then
  warn "rustup already installed"
else
  info "Installing Rust via rustup ..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  ok "Rust $(rustc --version) installed"
fi

# ---------------------------------------------------------------------------
# 3b. Go
# ---------------------------------------------------------------------------

if has go; then
  warn "go $(go version) already installed"
else
  info "Installing Go ..."
  install_pkg golang
  ok "Go installed"
fi

# ---------------------------------------------------------------------------
# 4. Node.js
# ---------------------------------------------------------------------------

if has node; then
  warn "node $(node --version) already installed"
else
  info "Installing Node.js LTS ..."
  install_pkg nodejs-lts
  ok "Node $(node --version) installed"
fi

# ---------------------------------------------------------------------------
# 5. Python extras
# ---------------------------------------------------------------------------

info "Installing Python extras ..."
install_pkg python-pip python-pygments

# ---------------------------------------------------------------------------
# 6. Zsh + Oh My Zsh
# ---------------------------------------------------------------------------

if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh ..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Antigen (zsh plugin manager)
if [ -f "$HOME/antigen.zsh" ]; then
  warn "antigen.zsh already present"
else
  info "Downloading antigen ..."
  curl -fsSL https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh > "$HOME/antigen.zsh"
fi

# ---------------------------------------------------------------------------
# 7. Deploy dotfiles
# ---------------------------------------------------------------------------

info "Deploying dotfiles from $TERMUX_HOME ..."

# Copy home dotfiles
cp -rv "$TERMUX_HOME/." "$HOME/"

# Ensure .termux dir exists and copy termux-specific config
if [ -d "$DOTFILES_DIR/termux/home/.termux" ]; then
  mkdir -p "$HOME/.termux"
  cp -rv "$DOTFILES_DIR/termux/home/.termux/." "$HOME/.termux/"
  # Reload termux settings
  termux-reload-settings 2>/dev/null || true
fi

ok "Dotfiles deployed"

# ---------------------------------------------------------------------------
# 8. Neovim config
# ---------------------------------------------------------------------------

NVIM_CONFIG="$HOME/.config/nvim"

if [ -d "$NVIM_CONFIG/.git" ]; then
  warn "nvim config already cloned, pulling latest ..."
  git -C "$NVIM_CONFIG" pull || true
else
  info "Cloning nvim config ..."
  mkdir -p "$HOME/.config"
  git clone https://github.com/codyduong/nvim.git "$NVIM_CONFIG"
  ok "nvim config deployed to $NVIM_CONFIG"
fi

# ---------------------------------------------------------------------------
# 9. Set default shell to zsh
# ---------------------------------------------------------------------------

if [ "$(basename "$SHELL")" != "zsh" ]; then
  info "Setting default shell to zsh ..."
  chsh -s zsh
  ok "Default shell set to zsh"
else
  warn "zsh is already the default shell"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
ok "Bootstrap complete! Restart Termux or run: exec zsh"
echo ""
info "Installed: git, tmux, zsh, neovim, fzf, ripgrep, fd, bat, delta,"
info "           jq, zoxide, rust, go, node, python, openssh"
echo ""
info "tmux config: ~/.tmux.conf  (Ctrl+Space prefix)"
info "Termux keys: ~/.termux/termux.properties"
echo ""
