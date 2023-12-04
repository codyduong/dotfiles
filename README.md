# dotfiles
My "dotfiles" for linux/windows with bootstrap scripts

## Linux
For Ubuntu distros... TODO other distros

### Start

**with curl**
```bash
sudo apt install curl -y >/dev/null
which curl >/dev/null
  && curl https://raw.githubusercontent.com/codyduong/dotfiles/main/linux/install.sh | bash
  || echo "\033[1;31mbootstrap failed\033[0m"
```
**with git**
```bash
git clone https://github.com/codyduong/dotfiles ~/dotfiles &&
dotfiles/linux/bootstrap.sh
```

## Windows

### Pre-reqs
* [Powershell 7.2^](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  ```powershell
  # in terminal/cmd
  winget install --id Microsoft.Powershell --source winget
  winget install --id Microsoft.Powershell.Preview --source winget
  ```

### Bootstrap Profile
**without git**
```powershell
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/codyduong/dotfiles/main/windows/setup/remote.ps1'))
```
**with git**
```powershell
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/codyduong/dotfiles/main/windows/setup/git.ps1'))
```

### Features
TO-DO

### Issues
* **Problem**: Powershell profile is not saved in start menu.
* **Solution**: Run powershell as admin, copy working `.lnk`
  ```powershell
  cp "$PROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\PowerShell 7-preview (x64).lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerShell\" 
  ```
<!--- https://superuser.com/a/171129 
Pinned Menu: %AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar
Start Menu (loc 1): %AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu
Start Menu (loc 2): C:\ProgramData\Microsoft\Windows\Start Menu\Programs
-->



<!---
## Windows 10
https://github.com/mgth/LittleBigMouse
* [VS Code](https://code.visualstudio.com/#alt-downloads)
* [Git](https://git-scm.com/downloads)
* [GNUPG (Commit Signing)](https://www.gnupg.org/download/)
```sh
# https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/generating-a-new-gpg-key
gpg --full-generate-key
# Enter for RSA and RSA (default)
# 4096 bits (Github min)
# No expiration (Expire from Github if needed)
gpg --list-secret-keys --keyid-format LONG 
# Copy GPG Key (listed one is an example)
gpg --armor --export 3AA5C34371567BD2 #<-- Give to Github 
git config --global user.signingkey 3AA5C34371567BD2 #<-- Git Bash, tell Git about signing key
```
* [Github Desktop](https://desktop.github.com/) (I should migrate to [GitKraken](https://www.gitkraken.com/git-client), looks better)
* [TDM-GCC (gcc, g++, make)](https://jmeubank.github.io/tdm-gcc/)
* [Python ^3 ](https://www.microsoft.com/en-us/p/python-39/9p7qfqmjrfp7)
  * [thefuck](https://github.com/nvbn/thefuck) =>
    ```sh
    pip install thefuck
    ```
    Add thefuck to ENV Path. Usually at:
    ```C:\Users\duong\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts```
    Then create $PROFILE for Alias
    ```sh
    if (!(Test-Path -Path $PROFILE)) {New-Item -ItemType File -Path $PROFILE -Force}
    notepad $PROFILE
    ```
    Inside the $PROFILE
    ```notepad
    $env:PYTHONIOENCODING="utf-8"
    iex "$(thefuck --alias)"
    ```
* [Node](https://nodejs.org/en/)
  * [Yarn](https://classic.yarnpkg.com/en/docs/install/#windows-stable) => ```npm install --global yarn```
* [Deno](https://deno.land/) => ```iwr https://deno.land/x/install/install.ps1 -useb | iex```

Utility Software (less important, but if I want it):
* The razer things for razer stuff?
* [QTTabbar](https://github.com/indiff/qttabbar)
* I always forget about this one, *printer drivers!*
* [Dual Monitor Tools](http://dualmonitortool.sourceforge.net/)
* [Artist 12 Drivers](https://www.xp-pen.com/download-68.html)
* [Taskbar X](https://chrisandriessen.nl/taskbarx)
* [ScanTailor](https://github.com/scantailor/scantailor)
* [LibreOffice](https://www.libreoffice.org/)

## Ubuntu
.deb
* [VS Code](https://code.visualstudio.com/#alt-downloads)
* [GitKraken](https://www.gitkraken.com/git-client)

CLI
* [GNUPG (Commit Signing)](https://www.gnupg.org/download/) ```Comes preinstalled, instructions are exact same as above```
* [Git](https://git-scm.com/downloads) OR ```sudo apt install git```
  * policykit1-gnome ```sudo apt install policykit-1-gnome```
  ```sh 
  git clone https://github.com/codyduong/shopping-list/
  sudo cp ./shopping-list/userLinux/.config -r ~
  sudo cp ./shopping-list/userLinux/.Xresources ~
  sudo cp -a ./shopping-list/userLinux/Solarized-Dark-Cyan-3.36/ /usr/share/themes/
  # This is for the triple setup, you may have to manually set this,
  # sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config
  sudo cp ./shopping-list/userLinux/monitors.xml /var/lib/gdm3/.config
  ```
* gcc, g++, make => ```sudo apt install build-essential```
* Python ^3 => ```sudo apt install python3-dev python3-pip python3-setuptools```
  * [thefuck](https://github.com/nvbn/thefuck) => ```sudo pip3 install thefuck```
  * ```sudo apt install pipenv```
* [Node](https://nodejs.org/en/) ```sudo apt install nodejs```
  * npm ```sudo apt-get install npm``` 
  ```sh
  sudo npm install -g n
  sudo n stable #or version number, or latest
  ```
  * [Yarn](https://classic.yarnpkg.com/en/docs/install#debian-stable) ```sudo npm install --global yarn```
* [Deno](https://deno.land/#installation) ```curl -fsSL https://deno.land/x/install/install.sh | sh```
* [i3](https://i3wm.org/) ```sudo apt install i3```

All as one
```sh
sudo apt install git -y
sudo apt install curl -y

git clone https://github.com/codyduong/shopping-list/ &&
sudo cp ./shopping-list/userLinux/.config -r ~ &&
sudo cp ./shopping-list/userLinux/.Xresources ~ &&
sudo cp -a ./shopping-list/userLinux/Solarized-Dark-Cyan-3.36/ /usr/share/themes/ &&
sudo cp ./shopping-list/userLinux/monitors.xml /var/lib/gdm3/.config

# python and fuck
sudo apt install build-essential -y
sudo apt install python3-dev python3-pip python3-setuptools -y &&
sudo pip3 install thefuck &&
fuck &&
fuck &&

# python package managers
sudo apt install pipenv -y &&
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 &&
source $HOME/.poetry/env

# node, npm, yarn, and deno
sudo apt install nodejs -y &&
sudo apt-get install npm -y &&
sudo npm install --global yarn -y &&
sudo npm install -g n &&
sudo n latest
curl -fsSL https://deno.land/x/install/install.sh | sh

# i3
sudo apt install i3 -y

# vs-code
sudo apt-get install wget gpg -y &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg &&
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
rm -f packages.microsoft.gpg &&
sudo apt install apt-transport-https -y &&
sudo apt update &&
sudo apt install code -y # or code-insiders

# oh-my-zsh
sudo apt install zsh -y &&
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# oh-my-zsh leaves terminal, TODO patch
# append to .zshrc to agnoster
sudo apt-get install fonts-powerline

```

Utility Software (less important, but if I want it):
* [Polychromatic](https://polychromatic.app/)
* [Artist 12 Drivers](https://www.xp-pen.com/download-68.html)
-->
