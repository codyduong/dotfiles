[CmdletBinding()]
param (
  [switch]
  $update
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

if ($update.IsPresent) {
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

##########
# Terminal
##########
Write-Host "`nInstalling PowerShell and Extensions..." -ForegroundColor "Yellow"
Install-GitHubRelease winget microsoft/winget-cli "Microsoft\.DesktopAppInstaller_.*\.msixbundle$"
Install-Winget Microsoft.Powershell
Install-PowerShell PSWindowsUpdate -Scope CurrentUser -Force
Install-PowerShell PSProfiler -Scope CurrentUser -Force -SkipPublisherCheck -AllowPrerelease
Install-PowerShell git-aliases-plus -Scope CurrentUser -Force -AllowClobber
Install-PowerShell alias-tips -Scope CurrentUser -Force -AllowClobber -AllowPrerelease
Install-PowerShell Posh-Git -Scope CurrentUser -Force
Install-PowerShell PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-PowerShell -Name CompletionPredictor -Scope CurrentUser -Force -SkipPublisherCheck

### Install oh-my-posh and dependencies
Install-Winget JanDeDobbeleer.OhMyPosh
Install-PowerShell -Name Terminal-Icons -Repository PSGallery -Force
oh-my-posh font install Meslo

#################
# Developer Tools
#################
Write-Host "`nInstalling IDEs/Editors..." -ForegroundColor "Yellow"
Install-Winget Microsoft.VisualStudioCode
Install-Winget vim.vim
Install-Winget Neovim.Neovim

Write-Host "`nInstalling Developer Tools..." -ForegroundColor "Yellow"
Install-Winget Microsoft.PowerToys
Install-Winget Git.Git
Install-GitHubRelease git-credential-manager git-ecosystem/git-credential-manager "gcmuser-win-x.*\.exe$" -version $(git credential-manager --version)
git credential-manager configure
Install-Winget GnuWin32.Grep
Install-Winget Docker.DockerDesktop

Write-Host "`nInstalling Languages..." -ForegroundColor "Yellow"
Write-Host "NodeJS" -ForegroundColor "Cyan"
# NodeJS
# Install-Winget OpenJS.NodeJS
Install-Winget CoreyButler.NVMforWindows
npm install -g npm@latest
npm install -g yarn

Write-Host "`nPython" -ForegroundColor "Cyan"
# Python
Install-Winget Python.Python.3.9
python.exe -m pip install --upgrade pip -q
pip install thefuck -q
pip install pyenv-win --target $HOME\\.pyenv -q

Write-Host "`nRust" -ForegroundColor "Cyan"
# Rust
Install-Winget Rustlang.Rustup
cargo install ripgrep

##############
# Desktop Apps
##############
Write-Host "`nInstalling Desktop Apps..." -ForegroundColor "Yellow"
# PERSONAL
Install-Winget Discord.Discord
Install-Winget Valve.Steam

# BROWSERS
Install-Winget Google.Chrome
Install-Winget Google.Chrome.Canary
Install-Winget Mozilla.Firefox.ESR # Extended Support Release
Install-Winget Mozilla.Firefox.DeveloperEdition 

# WORK/PRODUCTIVE
Install-Winget Zoom.Zoom
Install-Winget Microsoft.Teams
Install-Winget SlackTechnologies.Slack

# PATCH W11
# https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
if (([Environment]::OSVersion.Version).Build -ge 22621) {
  Install-Winget valinet.ExplorerPatcher
}

#####
# WSL
#####
Write-Host "`nInstalling WSL" -ForegroundColor "Yellow"
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