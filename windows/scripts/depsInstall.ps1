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
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force


### Install oh-my-posh and others
Write-Host "Installing oh-my-posh and extensions..." -ForegroundColor "Yellow"
winget install JanDeDobbeleer.OhMyPosh -s winget
# autocomplete
Install-Module PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
# predictor for autocomplete
Install-Module -Name CompletionPredictor -Scope CurrentUser -Force -SkipPublisherCheck
# terminal icons
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
# oh-my-zsh like git aliases
# TODO this throws import errors
# Install-Module git-aliases -Scope CurrentUser -AllowClobber -Force
# font
oh-my-posh font install Meslo

# profiling
Install-Module PSProfiler -Scope CurrentUser -Force -SkipPublisherCheck -AllowPrerelease

### Install ExplorePatcher if win11, TODO
# WingetInstall("valinet.ExplorerPatcher")


### Desktop Utilities
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which cinst)) {
   iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
   Refresh-Environment
   choco feature enable -n=allowGlobalConfirmation
}

# PERSONAL
WingetInstall("Discord.Discord")
WingetInstall("Valve.Steam")

# BROWSERS
WingetInstall("Google.Chrome")
WingetInstall("Google.Chrome.Canary")
WingetInstall("Mozilla.Firefox.ESR") # Extended Support Release
WingetInstall("Mozilla.Firefox.DeveloperEdition ")

# PRODUCTIVE
WingetInstall("Zoom.Zoom")

# DEV DEPS
choco install curl                --limit-output # awaiting winget
WingetInstall("OpenJS.NodeJS")
WingetInstall("CoreyButler.NVMforWindows")
WingetInstall("Python.Python.3.9")
choco install pyenv-win
WingetInstall("GitHub.GitHubDesktop")
WingetInstall("Git.Git")
WingetInstall("Microsoft.GitCredentialManagerCore")

Write-Host "Installing IDEs..." -ForegroundColor "Yellow"
# IDEs / DEs
WingetInstall("Microsoft.VisualStudioCode")
WingetInstall("vim.vim")
WingetInstall("Neovim.Neovim")

# SCOOP
irm get.scoop.sh | iex

# grep
WingetInstall("GnuWin32.Grep")

Refresh-Environment

nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

### Windows Features
# Write-Host "Installing Windows Features..." -ForegroundColor "Yellow"
# IIS Base Configuration
# Enable-WindowsOptionalFeature -Online -All -FeatureName `
#    "IIS-BasicAuthentication", `
#    "IIS-DefaultDocument", `
#    "IIS-DirectoryBrowsing", `
#    "IIS-HttpCompressionDynamic", `
#    "IIS-HttpCompressionStatic", `
#    "IIS-HttpErrors", `
#    "IIS-HttpLogging", `
#    "IIS-ISAPIExtensions", `
#    "IIS-ISAPIFilter", `
#    "IIS-ManagementConsole", `
#    "IIS-RequestFiltering", `
#    "IIS-StaticContent", `
#    "IIS-WebSockets", `
#    "IIS-WindowsAuthentication" `
#    -NoRestart | Out-Null

# ASP.NET Base Configuration
# Enable-WindowsOptionalFeature -Online -All -FeatureName `
#    "NetFx3", `
#    "NetFx4-AdvSrvs", `
#    "NetFx4Extended-ASPNET45", `
#    "IIS-NetFxExtensibility", `
#    "IIS-NetFxExtensibility45", `
#    "IIS-ASPNET", `
#    "IIS-ASPNET45" `
#    -NoRestart | Out-Null

# Web Platform Installer for remaining Windows features
# webpicmd /Install /AcceptEula /Products:"UrlRewrite2"

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
   npm update npm
   # npm install -g gulp
   # npm install -g mocha
   # npm install -g node-inspector
   # npm install -g yo
   npm install -g yarn
}

# wsl
wsl --install
