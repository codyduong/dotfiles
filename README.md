# shopping-list
A list of things I need to do on a clean install

## Software Specifics
This contains shell/terminal commands for specific stuff

### Windows 10
* Git https://git-scm.com/downloads
* Github Desktop https://desktop.github.com/
* TDM-GCC: https://jmeubank.github.io/tdm-gcc/ (gcc, g++, make)
* Python ^3
  * thefuck https://github.com/nvbn/thefuck
    ```sh
    pip install thefuck
    ```
    Add thefuck to ENV Path. Then create $PROFILE for Alias
    ```sh
    if (!(Test-Path -Path $PROFILE)) {
      New-Item -ItemType File -Path $PROFILE -Force
    }
    # Then access $PROFILE
    notepad $PROFILE
    ```
    Inside the $PROFILE
    ```notepad
    $env:PYTHONIOENCODING="utf-8"
    iex "$(thefuck --alias)"
    ```
* Node https://nodejs.org/en/
  * Yarn ```npm install --global yarn```
* Deno https://deno.land/ ```iwr https://deno.land/x/install/install.ps1 -useb | iex```

### Ubuntu
* Git ```sudo apt install git-all```
* Github Desktop Fork https://aur.archlinux.org/packages/github-desktop-bin/ (.deb)
* gcc, g++, make ```sudo apt install build-essential```
* Python ^3 ```sudo apt install python3-dev python3-pip python3-setuptools```
  * thefuck https://github.com/nvbn/thefuck ```sudo pip3 install thefuck```
* Node https://nodejs.org/en/
  * Yarn ```npm install --global yarn```
* Deno ```curl -fsSL https://deno.land/x/install/install.sh | sh```
