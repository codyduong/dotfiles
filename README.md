A list of things I need to do on a clean install

## Windows 10
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

Utility Software:
* The razer things for razer stuff?
* [QTTabbar](https://github.com/indiff/qttabbar)
* I always forget about this one, *printer drivers!*
* [Dual Monitor Tools](http://dualmonitortool.sourceforge.net/)
* [Artist 12 Drivers](https://www.xp-pen.com/download-68.html)
* [Taskbar X](https://chrisandriessen.nl/taskbarx)
* [ScanTailor](https://github.com/scantailor/scantailor)
* [LibreOffice](https://www.libreoffice.org/)

## Ubuntu
* [CheckInstall](https://help.ubuntu.com/community/CheckInstall)
```sh 
sudo apt-get update && sudo apt-get install checkinstall
```
* [VS Code](https://code.visualstudio.com/#alt-downloads)
* [Git](https://git-scm.com/downloads) OR ```sudo apt install git-all```
* [GNUPG (Commit Signing)](https://www.gnupg.org/download/)
```Comes preinstalled, instructions are exact same as above```
* [GitKraken](https://www.gitkraken.com/git-client)
* gcc, g++, make => ```sudo apt install build-essential```
* Python ^3 => ```sudo apt install python3-dev python3-pip python3-setuptools```
  * [thefuck](https://github.com/nvbn/thefuck) => ```sudo pip3 install thefuck```
* [Node](https://nodejs.org/en/) ```sudo apt install nodejs```
  * npm ```sudo apt-get install npm``` 
  ```sh
  sudo npm install -g n
  sudo n stable #or version number, or latest
  ```
  * [Yarn](https://classic.yarnpkg.com/en/docs/install#debian-stable)
* [Deno](https://deno.land/#installation) ```curl -fsSL https://deno.land/x/install/install.sh | sh```
* [i3](https://i3wm.org/) ```sudo apt install i3```

Utility Software:
* [Polychromatic](https://polychromatic.app/)
* [Artist 12 Drivers](https://www.xp-pen.com/download-68.html)
