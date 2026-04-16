# ---------------------------------------------------------------------------
# Termux .zshrc
# ---------------------------------------------------------------------------

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

# Antigen (plugin manager)
if [ -f "$HOME/antigen.zsh" ]; then
  source "$HOME/antigen.zsh"
  antigen use oh-my-zsh
  antigen bundle git
  antigen bundle command-not-found
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle common-aliases
  antigen bundle djui/alias-tips
  antigen bundle pip
  antigen theme agnoster
  antigen apply
else
  # Fallback: just load oh-my-zsh with basic plugins
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
fi

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------

export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim

# History
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=50000
SAVEHIST=50000

# ---------------------------------------------------------------------------
# Tool initialization
# ---------------------------------------------------------------------------

# Cargo / Rust
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

alias cls="clear"
alias reload="exec zsh"
alias vim="nvim"
alias vi="nvim"

# bat as cat replacement (Termux package is 'bat')
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
  alias catp="bat"
fi

# ls with color
alias ls="ls --color=auto"
alias ll="ls -lah"
alias la="ls -A"

# ripgrep
alias rg="rg --smart-case"

# git shortcuts (supplement oh-my-zsh git plugin)
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -20"

# ---------------------------------------------------------------------------
# tmux helper (sets TMUX user var for wezterm integration when over SSH)
# ---------------------------------------------------------------------------

function tmux_entry() {
  local tmux_config="$HOME/.tmux.conf"

  if [[ "$#" -gt 0 && "$1" == "-f" ]]; then
    tmux_config="$2"
    shift 2
  fi

  # Set iterm2/wezterm user var for tmux detection
  printf "\033]1337;SetUserVar=%s=%s\007" "TMUX" "$(echo -n '1' | base64)"
  command tmux -f "$tmux_config" "$@"
  printf "\033]1337;SetUserVar=%s=\007" "TMUX"
}
alias tmux='tmux_entry'

# Auto-attach to tmux session on Termux launch (if not already in tmux)
if [ -z "$TMUX" ] && [ -n "$TERMUX_VERSION" ]; then
  tmux_entry new-session -A -s main
fi
