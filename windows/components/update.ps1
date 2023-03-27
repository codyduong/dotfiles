. $PSScriptRoot\utils.ps1

$script:account           = "codyduong"
$script:repo              = "dotfiles"
$script:branch            = "main"
$script:remoteVersionUrl  = "https://raw.githubusercontent.com/$account/$repo/$branch/windows/profile.ps1"
$script:latestVersionFile = [System.IO.Path]::Combine("$HOME",'.latest_profile_version')
$script:versionRegEx      = "# [vV]ersion (?<version>\d+\.\d+\.\d+)"
$script:dotfiles          = [System.IO.Path]::Combine("$HOME","$repo")

function getProfileVersions {
  "Current: $currentVersion    Available: $latestVersion"
}

function promptProfileUpdate {
  if (isProfileOutdated) {
    $choice = PromptBooleanQuestion "Profile update available $currentVersion -> $latestVersion, install" $true
    if ($choice) {
      updateProfile
    }
  }
  else {
    # Write-Host "Powershell Profile $currentVersion ($(Join-Path (Split-Path -parent $profile) "profile.ps1"))" 
  }
}

function forceProfileCheck {
  $null = Start-ThreadJob -Name "Get remote version" -StreamingHost $Host -ArgumentList $remoteVersionUrl, $latestVersionFile, $versionRegEx -ScriptBlock {
    param ($remoteVersionUrl, $latestVersionFile, $versionRegEx)

    $latestVersion = [System.IO.File]::ReadAllText($latestVersionFile)

    if (Test-Path "$dotfiles\.git") {
      # Check via repo if we have
      param ($dotfiles)
      Set-Location $dotfiles
      [boolean]$stashed = $false
      [string]$stashName = New-Guid
      try {
        $stashed = (git stash push -u -m $stashName)
      }
      catch {}
      $old_branch = (git rev-parse --abbrev-ref HEAD)
      git checkout $branch
      git fetch
      git pull
      $profileFile = [System.IO.File]::ReadAllText("$dotfiles\windows\profile.ps1")
      git checkout $old_branch
      if ($stashed) {
        git stash pop
      }
    }
    else {
      # Check via remote if we can
      $profileFile = Invoke-WebRequest -Uri $remoteVersionUrl -UseBasicParsing
    }
    [version]$remoteVersion = "0.0.0"
    if ($profileFile -match $versionRegEx) {
      $remoteVersion = $matches.Version
      if ($remoteVersion -gt [version]$latestVersion) {
        Set-Content -Path $latestVersionFile -Value $remoteVersion
      }
    }
  }
}

function isProfileOutdated {
  [boolean]$isOutdated = $false
  if ([System.IO.File]::Exists($latestVersionFile)) {
    $global:latestVersion = [version][System.IO.File]::ReadAllText($latestVersionFile)
    $global:currentProfile = [System.IO.File]::ReadAllText((Join-Path (Split-Path -parent $profile) "profile.ps1"))
    [version]$global:currentVersion = "0.0.0"
    if ($currentProfile -match $versionRegEx) {
      $global:currentVersion = $matches.Version
    }
    if ([version]$latestVersion -gt $currentVersion) {
      $isOutdated = $true
    }
  }

  forceProfileCheck
  
  $isOutdated
}

function updateProfile() {
  if (Test-Path "$dotfiles\.git") {
    $old_location = Get-Location
    Set-Location $dotfiles
    try {
      [boolean]$stashed = $false
      [string]$stashName = New-Guid
      try {
        $stashed = (git stash push -u -m $stashName)
      }
      catch {}
      $old_branch = (git rev-parse --abbrev-ref HEAD)
      git checkout $branch
      git fetch
      git pull
      . .\windows\scripts\bootstrap.ps1 -update;
      git checkout $old_branch
      if ($stashed) {
        git stash pop
      }
    }
    finally {
      Invoke-Command { & "pwsh.exe" -NoLogo -command "& Set-Location $old_location" } -NoNewScope
    }
  }
  else {
    . $PSScriptRoot/../setup/remote.ps1 $true
    Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
  }
}

$null = promptProfileUpdate