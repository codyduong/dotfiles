# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
  $newProcess.Verb = "runas";
  [System.Diagnostics.Process]::Start($newProcess);

  exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
# Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
# Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
# oh-my-zsh like
Install-Module oh-my-posh -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force
# autocomplete
Install-Module PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
# terminal icons
Install-Module -Name Terminal-Icons -Repository PSGallery -Force

### Chocolatey
# installs choclatey, but all new stuff should be with winget
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which cinst)) {
   iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
   Refresh-Environment
   choco feature enable -n=allowGlobalConfirmation
}

# PERSONAL
winget install -e --id Discord.Discord
winget install -e --id Valve.Steam

# BROWSERS
winget install -e --id Google.Chrome
winget install -e --id Google.Chrome.Canary
winget install -e --id Mozilla.Firefox.ESR # Extended Support Release
winget install -e --id Mozilla.Firefox.DeveloperEdition 

# PRODUCTIVE
winget install -e --id Zoom.Zoom

# SYSTEM
choco install curl                --limit-output # awaiting winget
winget install -e --id OpenJS.NodeJS
winget install -e --id Python.Python.3.9
winget install -e --id CoreyButler.NVMforWindows
winget install -e --id GitHub.GitHubDesktop
winget install -e --id Git.Git
winget install -e --id Microsoft.GitCredentialManagerCore

# oh-my-posh
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install Meslo

# IDEs / DEs
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id vim.vim
winget install -e --id Neovim.Neovim

# FONTS
choco install sourcecodepro       --limit-output

# SCOOP
irm get.scoop.sh | iex

# grep
winget install -e --id GnuWin32.Grep

# less
# broken?
# winget install -e --id JohnTaylor.less

# # system and cli
# choco install curl                --limit-output
# choco install nuget.commandline   --limit-output
# choco install webpi               --limit-output
# choco install git.install         --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
# choco install nvm.portable        --limit-output
# choco install python              --limit-output
# choco install ruby                --limit-output

# #fonts
# choco install sourcecodepro       --limit-output

# # browsers
# choco install GoogleChrome        --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome        --limit-output
# choco install GoogleChrome.Canary --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome.Canary --limit-output
# choco install Firefox             --limit-output; <# pin; evergreen #> choco pin add --name Firefox             --limit-output
# choco install Opera               --limit-output; <# pin; evergreen #> choco pin add --name Opera               --limit-output

# # dev tools and frameworks
# choco install atom                --limit-output; <# pin; evergreen #> choco pin add --name Atom                --limit-output
# choco install Fiddler             --limit-output
# choco install vim                 --limit-output
# choco install winmerge            --limit-output

Refresh-Environment

nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

# gem pristine --all --env-shebang

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

### Janus for vim
# Write-Host "Installing Janus..." -ForegroundColor "Yellow"
# if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
#    curl.exe -L https://bit.ly/janus-bootstrap | bash
# }