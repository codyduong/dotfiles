#!/usr/bin/env bash

_curl() {
  which curl >/dev/null &&
    echo "\033[1;33mcurl found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling curl...\033[0m"
      sudo apt install curl -y
    )
}

_git() {
  which git >/dev/null &&
    echo "\033[1;33mgit found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling git...\033[0m"
      sudo apt install git -y
    )
}

_i3() {
  which i3 >/dev/null &&
    echo "\033[1;33mi3 found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling i3...\033[0m"
      sudo apt install i3 -y
    )
  which i3lock-fancy >/dev/null &&
    echo "\033[1;33mi3lock-fancy found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling i3lock-fancy...\033[0m"
      sudo apt install i3lock-fancy -y
    )
}

_zsh() {
  which zsh >/dev/null &&
    echo "\033[1;33mzsh found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling zsh\033...[0m"
      sudo apt install zsh -y
    )
}

_ohmyzsh() {
  _zsh && which oh-my-zsh >/dev/null &&
    echo "\033[1;33moh-my-zsh found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling oh-my-zsh\033...[0m"
      sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
      sudo apt-get install fonts-powerline
    )
}

_python() {
  which python >/dev/null &&
    curl https://pyenv.run | ohmyzsh
  sudo apt install build-essential -y
  sudo apt install python3-dev python3-pip python3-setuptools -y &&
    sudo pip3 install thefuck &&
    fuck &&
    fuck
}

_pyenv() {
  which pyenv >/dev/null &&
    echo "\033[1;33mpyenv found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling pyenv\033...[0m"
      curl https://pyenv.run | zsh
    )
}

_poetry() {
  which node >/dev/null &&
    echo "\033[1;33mpoetry found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling poetry\033...[0m"
      curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 &&
        source $HOME/.poetry/env
    )
}

_node() {
  which node >/dev/null &&
    echo "\033[1;33mnode found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling node\033...[0m"
      sudo apt install nodejs -y
    )

  which npm >/dev/null &&
    echo "\033[1;33mnpm found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling npm\033...[0m"
      sudo apt-get install npm -y
    )
}

_n() {
  which n >/dev/null &&
    echo "\033[1;33mn found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling n\033...[0m"
      sudo npm install -g n &&
        sudo n latest
    )
}

_yarn() {
  which yarn >/dev/null &&
    echo "\033[1;33myarn found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling yarn\033...[0m"
      sudo npm install --global yarn -y
    )
}

_deno() {
  which deno >/dev/null &&
    echo "\033[1;33mdeno found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling deno\033...[0m"
      curl -fsSL https://deno.land/x/install/install.sh | sh
    )
}

_wget() {
  which wget >/dev/null &&
    echo "\033[1;33mwget found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling wget\033...[0m"
      sudo apt-get install wget -y
    )
}

_gpg() {
  which gpg >/dev/null &&
    echo "\033[1;33mgpg found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling gpg\033...[0m"
      sudo apt-get install gpg -y
    )
}

_code() {
  which code >/dev/null &&
    echo "\033[1;33mcode found, skipping\033...[0m" ||
    (
      echo "\033[1;34minstalling code\033...[0m"
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg &&
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
        rm -f packages.microsoft.gpg &&
        sudo apt install apt-transport-https -y &&
        sudo apt update &&
        sudo apt install code -y
    )
}

_rust() {
  which rustup >/dev/null &&
    echo "\033[1;33mrust found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling rust...\033[0m"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    )
}

_ripgrep() {
  which ripgrep >/dev/null &&
    echo "\033[1;33mripgrep found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling ripgrep...\033[0m"
      sudo apt-get install ripgrep
    )
}

_pavucontrol() {
  which pavucontrol >/dev/null &&
    echo "\033[1;33mpavucontrol found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling pavucontrol...\033[0m"
      sudo apt install pavucontrol -y
    )
}

_brightnessctl() {
  which brightnessctl >/dev/null &&
    echo "\033[1;33mbrightnessctl found, skipping...\033[0m" ||
    (
      echo "\033[1;34minstalling brightnessctl...\033[0m"
      sudo apt install brightnessctl -y
    )
}

_theme() {
  echo "\033[1;34mAdding solarized themes to \\usr\\share\\themes\\033[0m"
  mkdir ~/tmp/solarized-themes
  git clone -n Solarized-Dark-gtk-theme-colorpack https://github.com/rtlewis88/rtl88-Themes.git ~/tmp/solarized-themes --depth 1
  rm ~/tmp/solarized-themes/*.png
  rm ~/tmp/solarized-themes/README.md
  sudo cp -a ~/tmp/solarized-themes/ /usr/share/themes/
  rm ~/tmp/solarized-themes -r
}

_dotfiles() {
  echo "\033[1;34mMoving dotfiles (home) to ~\033[0m"
  sudo cp ~/dotfiles/linux/home/. -r ~/
}

_otherfiles() {
  echo "\033[1;34mCopying other files\033[0m"
  sudo cp ~/dotfiles/linux/var/lib/gdm3/.config /var/lib/gdm3/.config
}

_curl
_git
_i3
_ohmyzsh
_python
_pyenv
_poetry
_node
_n
_yarn
_deno
_wget
_gpg
_code
_rust
_ripgrep
_pavucontrol
_brightnessctl
_theme
_dotfiles
_otherfiles
