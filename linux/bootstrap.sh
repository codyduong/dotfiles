#!/usr/bin/env bash

# sudo apt install git -y
# sudo apt install curl -y

# git clone https://github.com/codyduong/shopping-list/ &&
# sudo cp ./shopping-list/userLinux/.config -r ~ &&
# sudo cp ./shopping-list/userLinux/.Xresources ~ &&
# sudo cp -a ./shopping-list/userLinux/Solarized-Dark-Cyan-3.36/ /usr/share/themes/ &&
# sudo cp ./shopping-list/userLinux/monitors.xml /var/lib/gdm3/.config

_curl() {
  which curl >/dev/null
    && echo "\033[1;33mcurl installation found, skipping\033[0m"
    || (echo "\033[1;33minstalling curl\033[0m"; sudo apt install curl -y)
}

_git() {
  which git >/dev/null 
    && echo "\033[1;33mgit installation found, skipping\033[0m"
    || (echo "\033[1;33minstalling git\033[0m"; sudo apt install git -y)
}

_i3() {
  which i3 >/dev/null
    && echo "\033[1;33mi3 installation found, skipping\033[0m"
    || (echo "\033[1;33minstalling i3\033[0m"; sudo apt install i3 -y)
  which i3lock-fancy >/dev/null
    && echo "\033[1;33mi3lock-fancy installation found, skipping\033[0m"
    || (echo "\033[1;33minstalling i3lock-fancy\033[0m"; sudo apt install i3lock-fancy -y) 
}

_python() {
  curl https://pyenv.run | ohmyzsh
  sudo apt install build-essential -y
  sudo apt install python3-dev python3-pip python3-setuptools -y &&
  sudo pip3 install thefuck &&
  fuck &&
  fuck
}

_pyenv() {
  which pyenv >/dev/null &&
    echo "\033[1;33mpyenv installation found, skipping\033[0m" || 
    (echo "\033[1;33minstalling pyenv\033[0m"; curl https://pyenv.run | zsh)
}

_poetry() {
  curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 &&
  source $HOME/.poetry/env
}

# node, npm, yarn, n, and deno
_node() {
  sudo apt install nodejs -y &&
  sudo apt-get install npm -y &&
  sudo npm install --global yarn -y &&
  sudo npm install -g n &&
  sudo n latest
  curl -fsSL https://deno.land/x/install/install.sh | sh
}

_code() {
  sudo apt-get install wget gpg -y &&
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg &&
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
  rm -f packages.microsoft.gpg &&
  sudo apt install apt-transport-https -y &&
  sudo apt update &&
  sudo apt install code -y
}

_ohmyzsh() {
  sudo apt install zsh -y &&
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  sudo apt-get install fonts-powerline
}

_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

_ripgrep() {
  which rg>/dev/null
    && echo "\033[1;33mripgrep installation found, skipping\033[0m" 
    || (echo "\033[1;33minstalling ripgrep\033[0m"; sudo apt-get install ripgrep)
}

_curl
_git
_i3
_python
_pyenv
_poetry
_node
_code
_ohmyzsh
_rust
_ripgrep
