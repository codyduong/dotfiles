[CmdletBinding()]
param (
  [switch]
  $update
)

. $PSScriptRoot\utils.ps1

if ($update.IsPresent) {
  $Env:UPDATE_OUTDATED_DEPS = $update
}
else {
  InstallerPromptUpdateOutdated
}

$script:currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)

### Update Help for Modules
# Write-Host "Updating Help..." -ForegroundColor "Yellow"
# Update-Help -Force

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
if ($true) {
  # Actual deps
  Install-PowerShell -Name PowershellHumanizer -Force

  $script:TerminalIconsForkPath = (Join-Path $env:USERPROFILE "Terminal-Icons")
  $script:TerminalIconsCloned = $false

  # Clone a fork of Terminal-Icons
  if (-not (Test-Path -Path $TerminalIconsForkPath -PathType Container)) {
    Write-Host "Cloning Terminal-Icons (fork) v$TerminalIconsVersion..." -ForegroundColor $InstallationIndicatorColorInstalling
    git clone https://github.com/codyduong/Terminal-Icons.git "$TerminalIconsForkPath"
    $script:TerminalIconsCloned = $true
  }

  # Pull if possible
  $script:gpOut = git -C "$TerminalIconsForkPath" pull
  
  if ($gitPullOutput -notlike '*Already up to date.*') {
    Write-Host "Pulling Terminal-Icons (fork)..." -ForegroundColor $InstallationIndicatorColorUpdating
  }
  else {
    Write-Host "Terminal-Icons (fork) up to date." -ForegroundColor $InstallationIndicatorColorFound
  }

  # Install actual deps
  $script:manifestData = Import-PowerShellDataFile -Path (Join-Path $TerminalIconsForkPath "Terminal-Icons/Terminal-Icons.psd1")

  foreach ($script:moduleName in $manifestData.RequiredModules) {
    Install-PowerShell -Name $moduleName -Force -RequiredVersion $moduleVersion
  }

  # Install build deps
  $script:manifestData = Import-PowerShellDataFile -Path (Join-Path $TerminalIconsForkPath "requirements.psd1")

  $script:psDependOptions = $manifestData.PSDependOptions

  $script:scope = if ($psDependOptions -and $psDependOptions.Target) {
    $psDependOptions.Target
  }
  else {
    'CurrentUser'
  }

  foreach ($script:moduleName in $manifestData.Keys) {
    if ($moduleName -eq 'PSDependOptions') {
      continue
    }

    $script:moduleVersion = $manifestData[$moduleName]

    if ($moduleVersion -eq 'latest') {
      Install-PowerShell -Name $moduleName -Force -Scope $scope
    }
    else {
      Install-PowerShell -Name $moduleName -Force -RequiredVersion $moduleVersion -Scope $scope
    }
  }

  $script:TerminalIconsVersion = (Import-PowerShellDataFile (Join-Path $TerminalIconsForkPath "Terminal-Icons/Terminal-Icons.psd1")).ModuleVersion

  # Build only if we haven't built the current version
  if (-not (Test-Path -Path (Join-Path $TerminalIconsForkPath "Output/Terminal-Icons/$TerminalIconsVersion") -PathType Container)) {
    if ($TerminalIconsCloned) {
      Write-Host "Building Terminal-Icons (fork) $TerminalIconsVersion..." -ForegroundColor $InstallationIndicatorColorInstalling
    }
    else {
      Write-Host "Building Terminal-Icons (fork) $TerminalIconsVersion..." -ForegroundColor $InstallationIndicatorColorUpdating
    }
    Push-Location
    Set-Location $TerminalIconsForkPath
    & (Join-Path $TerminalIconsForkPath "build.ps1")
    Pop-Location
  }
  else {
    Write-Host "Terminal-Icons (fork) $TerminalIconsVersion found, skipping build..." -ForegroundColor $InstallationIndicatorColorFound
  }
}

# Install Meslo if not already installed
$script:fonts = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
if (-not ($fonts.PSObject.Properties.name -contains 'Meslo LG S Bold Italic Nerd Font Complete Mono Windows Compatible (TrueType)')) {
  Invoke-ElevatedScript { oh-my-posh font install Meslo }
}

###########################
# Tiling Manager (komorebi)
###########################
Install-Winget LGUG2Z.whkd
Install-Winget LGUG2Z.komorebi
# AutoHotkey
Install-GitHubRelease ahk AutoHotkey/AutoHotkey ".*\.exe"

###################
# WezTerm
# tmux for windows!
###################
Install-Winget wez.wezterm

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
# TODO add script which properly updates git-credential-manager
# Note that gcmuser is for user install only! Use gcm-win-x for admin installs
Install-GitHubRelease git-credential-manager git-ecosystem/git-credential-manager "gcmuser-win-x.*\.exe$" -version $(
  "$(git credential-manager --version)" -replace "\+.*", "")
# TODO set up configuration step
# Make sure the credential helper is pointed in the right location
# git credential-manager configure
Install-Winget GnuWin32.Grep
Install-Winget Docker.DockerDesktop
Install-Winget jftuga.less
# Install-Powershell GoogleCloud -Scope CurrentUser
# Todo enable once we configure a gcloud init prompt (see https://cloud.google.com/tools/powershell/docs/quickstart)
Install-Winget Microsoft.Sysinternals.ProcessExplorer
Install-Winget BurntSushi.ripgrep.MSVC

Write-Host "`nInstalling Languages..." -ForegroundColor "Yellow"
Write-Host "NodeJS" -ForegroundColor "Cyan"
### NodeJS
Install-Winget OpenJS.NodeJS.LTS
Install-Winget CoreyButler.NVMforWindows
npm install -g npm@latest
npm install -g yarn

Write-Host "`nPython" -ForegroundColor "Cyan"
### Python
Install-Winget Python.Python.3.11
python.exe -m pip install --upgrade pip -q
# TODO these won't be in execution context upon first install
pip install thefuck -q
pip install pyenv-win --target $HOME\\.pyenv -q
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -

Write-Host "`nRust" -ForegroundColor "Cyan"
### Rust
# See https://github.com/rust-lang/rustup/pull/3047, on occasion it will read Unknown, add a custom GetCurrent ScriptBlock
Install-Winget Rustlang.Rustup -GetCurrent {
  try {
    if ((Get-Command rustup -ErrorAction SilentlyContinue) -and ($(rustup --version) -match "(?<=rustup)\s*[\d\.]+")) {
      [version]($matches[0])
    }
    else {
      [version]"0.0.0"
    }
  }
  catch {
    Write-Warning $_
    [version]"0.0.0"
  }
}

Write-Host "`nC/C++" -ForegroundColor "Cyan"
$script:msys2Path = "C:\msys64\usr\bin"
$script:mingwPath = "C:\msys64\ucrt64\bin"
# This has an superfluous call but idgaf. We really only care when the gcc version is updated, so use that as our baseline lib for when to upgrade
$script:msys2Remote = Invoke-RestMethod https://api.github.com/repos/msys2/msys2-installer/releases/latest
$script:msys2PackagesAsset = $msys2Remote.assets | Where-Object { $_.name -match "msys2-base-x86_64-latest.packages.txt" }
$script:msys2PackagesTxt = Join-Path $env:TEMP "Github" $msys2PackagesAsset.name
Invoke-WebRequest -Uri $msys2PackagesAsset.browser_download_url -OutFile $msys2PackagesTxt
$script:msys2RemoteVersion = if (Get-Content -Path $msys2PackagesTxt | Where-Object { $_ -match "(?<=gcc-libs )(\d+\.\d+\.\d+)" }) { $matches[0] } else { "0.0.0" }
# We use head instead of cat because there is some fuckery going on with Neovim/bin/cat.exe being on PATH that sometimes blows up msys2 bash cat
$script:msys2LocalVersion = "0.0.0"
try {
  $script:msys2LocalVersion = if (
    $(& $msys2Path\bash.exe -c "head /proc/version") -match "(?<=gcc version )\d+\.\d+\.\d+"
  ) { $matches[0] } else { "0.0.0" }
}
catch { Write-Warning $_ }
Install-GitHubRelease msys2 msys2/msys2-installer "msys2-x86_64-latest\.exe$" -version $msys2LocalVersion -remoteVersion $msys2RemoteVersion

# install mingw
Write-Verbose $(& $msys2Path\bash.exe -c "pacman -Syu base-devel mingw-w64-ucrt-x86_64-toolchain --noconfirm")

# Check if the path is already in the PATH variable
if ($currentPath -notlike "*$msys2Path*") {
  # Add the MSYS2 path to the PATH variable
  $newPath = $currentPath + ";" + $msys2Path
  [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::User)
  Write-Host "$msys2Path added to the PATH" -ForegroundColor "Green"
}
else {
  Write-Verbose "$msys2Path is already in the PATH"
}

if ($currentPath -notlike "*$mingwPath*") {
  # Add the MSYS2 path to the PATH variable
  $newPath = $currentPath + ";" + $mingwPath
  [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::User)
  Write-Host "$mingwPath added to the PATH" -ForegroundColor "Green"
}
else {
  Write-Verbose "$mingwPath is already in the PATH"
}

##############
# Desktop Apps
##############
Write-Host "`nInstalling Desktop Apps..." -ForegroundColor "Yellow"
### PERSONAL
Install-Winget Discord.Discord
Install-Winget Valve.Steam

### BROWSERS
Install-Winget Google.Chrome
Install-Winget Google.Chrome.Canary
Install-Winget Mozilla.Firefox.ESR # Extended Support Release
Install-Winget Mozilla.Firefox.DeveloperEdition 

### WORK/PRODUCTIVE
Install-Winget Zoom.Zoom
Install-Winget Microsoft.Teams
Install-Winget SlackTechnologies.Slack
Install-Winget OBSProject.OBSStudio

### PATCH W11
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
