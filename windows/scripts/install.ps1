[CmdletBinding(DefaultParametersetName = 'none')] 
param (
  [Parameter(Position = 0, ParameterSetName = "update")]$update
)

. $PSScriptRoot\utils.ps1
. $PSScriptRoot/../components/console.ps1

# Check to see if we are currently running "as Administrator"
# if (!(Verify-Elevated)) {
#   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
#   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
#   $newProcess.Verb = "runas";
#   [System.Diagnostics.Process]::Start($newProcess);

#   exit
# }

if ($null -ne $update) {
  $Env:UPDATE_OUTDATED_DEPS = $update
}
else {
  InstallerPromptUpdateOutdated
}

### Update Help for Modules
# Write-Host "Updating Help..." -ForegroundColor "Yellow"
# Update-Help -Force


### Package Providers
# Write-Host "`nInstalling Package Providers" -ForegroundColor "Yellow"
# Get-PackageProvider NuGet -Force | Out-Null
# # Chocolatey Provider is not ready yet. Use normal Chocolatey
# Get-PackageProvider Chocolatey -Force
# Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "`nInstalling PowerShell Extensions..." -ForegroundColor "Yellow"
PowershellInstall PSWindowsUpdate -Scope CurrentUser -Force -Verbose
PowershellInstall PSProfiler -Scope CurrentUser -Force -SkipPublisherCheck -AllowPrerelease -Verbose
PowershellInstall Posh-Git -Scope CurrentUser -Force -Verbose

### Install oh-my-posh and others
# Write-Host "`nInstalling OhMyPosh and Extensions" -ForegroundColor "Yellow"
WingetInstall JanDeDobbeleer.OhMyPosh
# autocomplete
PowershellInstall PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck -Verbose
# predictor for autocomplete
PowershellInstall -Name CompletionPredictor -Scope CurrentUser -Force -SkipPublisherCheck -Verbose
# terminal icons
PowershellInstall -Name Terminal-Icons -Repository PSGallery -Force -Verbose
oh-my-posh font install Meslo

################
#Developer Tools
################
Write-Host "`nInstalling IDEs/Editors..." -ForegroundColor "Yellow"
WingetInstall Microsoft.VisualStudioCode
WingetInstall vim.vim
WingetInstall Neovim.Neovim

Write-Host "`nInstalling Languages & Tools..." -ForegroundColor "Yellow"
WingetInstall Microsoft.PowerToys
# if ($null -eq (which cinst)) {
#    iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
#    Refresh-Environment
#    choco feature enable -n=allowGlobalConfirmation
# }
# curl is included by default
WingetInstall OpenJS.NodeJS
WingetInstall CoreyButler.NVMforWindows
WingetInstall Python.Python.3.9
WingetInstall Rustlang.Rustup
# https://github.com/microsoft/winget-pkgs/issues/17988
# choco install pyenv-win
# WingetInstall GitHub.GitHubDesktop
WingetInstall Git.Git
WingetInstall Microsoft.GitCredentialManagerCore
WingetInstall GnuWin32.Grep

# Node Setup
Write-Host "`nInstalling Node Packages..." -ForegroundColor "Yellow"
try {
  npm install -g npm@latest
  npm install -g yarn
}
catch {}
# $nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
# nvm install $nodeLtsVersion
# nvm use $nodeLtsVersion
# Remove-Variable nodeLtsVersion

###################
# Desktop Utilities
###################
Write-Host "`nInstalling Desktop Apps..." -ForegroundColor "Yellow"
# PERSONAL
WingetInstall Discord.Discord
WingetInstall Valve.Steam

# BROWSERS
WingetInstall Google.Chrome
WingetInstall Google.Chrome.Canary
WingetInstall Mozilla.Firefox.ESR # Extended Support Release
WingetInstall Mozilla.Firefox.DeveloperEdition 

# WORK/PRODUCTIVE
WingetInstall Zoom.Zoom
WingetInstall Microsoft.Teams
WingetInstall SlackTechnologies.Slack

# PATCH W11
# https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
if (([Environment]::OSVersion.Version).Build -ge 22621) {
  WingetInstall valinet.ExplorerPatcher
}

#######
# OTHER
#######

# SCOOP
# irm get.scoop.sh | iex

#####
# WSL
#####
try {
  wsl -v
}
catch {
  wsl --install
}

Write-Host @"

======== Installation Complete ========
If WSL was installed this run, you must 
reboot Windows for WSL to work properly

"@ -ForegroundColor White
Write-Host "  * Reloading shell automatically..." -ForegroundColor Cyan
Write-Host "=======================================`n" -ForegroundColor White
if (-not $update) {
  Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}