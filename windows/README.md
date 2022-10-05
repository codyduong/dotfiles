# Dotfiles for Windows
Based off [Jay Harris's dotfiles for Windows](https://github.com/jayharris/dotfiles-windows)

## Pre-reqs
* [Powershell 7.2^](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  ```powershell
  # in terminal/cmd
  winget install --id Microsoft.Powershell --source winget
  winget install --id Microsoft.Powershell.Preview --source winget
    ```

## Start
```powershell
iex ((new-object net.webclient).DownloadString('https://github.com/codyduong/dotfiles/master/setup/install.ps1'))
```