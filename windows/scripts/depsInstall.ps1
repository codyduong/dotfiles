# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
  $newProcess.Verb = "runas";
  [System.Diagnostics.Process]::Start($newProcess);

  exit
}

. $PSScriptRoot\utils.ps1
InstallerPromptUpdateOutdated

### Update Help for Modules
# Write-Host "Updating Help..." -ForegroundColor "Yellow"
# Update-Help -Force


## Package Providers
Write-Host "Installing chocolatey..." -ForegroundColor "Yellow"
# Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
Get-PackageProvider Chocolatey -Force
Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
PowershellInstall Posh-Git -Scope=CurrentUser -Force -Verbose
PowershellInstall PSWindowsUpdate -Scope CurrentUser -Force -Verbose


### Install oh-my-posh and others
Write-Host "Installing oh-my-posh and extensions..." -ForegroundColor "Yellow"
WingetInstall JanDeDobbeleer.OhMyPosh
# autocomplete
PowershellInstall PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck -Verbose
# predictor for autocomplete
PowershellInstall -Name CompletionPredictor -Scope CurrentUser -Force -SkipPublisherCheck -Verbose
# terminal icons
PowershellInstall -Name Terminal-Icons -Repository PSGallery -Force -Verbose
oh-my-posh font install Meslo

# profiling
PowershellInstall PSProfiler -Scope CurrentUser -Force -SkipPublisherCheck -AllowPrerelease -Verbose

### Install ExplorePatcher if win11, TODO
# WingetInstall valinet.ExplorerPatcher


### Desktop Utilities
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
# if ($null -eq (which cinst)) {
#    iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
#    Refresh-Environment
#    choco feature enable -n=allowGlobalConfirmation
# }

# PERSONAL
WingetInstall Discord.Discord
WingetInstall Valve.Steam

# BROWSERS
WingetInstall Google.Chrome
WingetInstall Google.Chrome.Canary
WingetInstall Mozilla.Firefox.ESR # Extended Support Release
WingetInstall Mozilla.Firefox.DeveloperEdition 

# PRODUCTIVE
WingetInstall Zoom.Zoom

# DEV DEPS
# curl is included by default
WingetInstall OpenJS.NodeJS
WingetInstall CoreyButler.NVMforWindows
WingetInstall Python.Python.3.9
# https://github.com/microsoft/winget-pkgs/issues/17988
choco install pyenv-win
WingetInstall GitHub.GitHubDesktop
WingetInstall Git.Git
WingetInstall Microsoft.GitCredentialManagerCore

Write-Host "Installing IDEs..." -ForegroundColor "Yellow"
# IDEs / DEs
WingetInstall Microsoft.VisualStudioCode
WingetInstall vim.vim
WingetInstall Neovim.Neovim

# grep
WingetInstall GnuWin32.Grep

# SCOOP
# irm get.scoop.sh | iex

Refresh-Environment

nvm on
# $nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
# nvm install $nodeLtsVersion
# nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
   npm update npm
   npm install -g yarn
}

# wsl
wsl --install
