. $PSScriptRoot\utils.ps1

$script:account           = "codyduong"
$script:repo              = "dotfiles"
$script:branch            = "main"
$script:remoteVersionUrl  = "https://raw.githubusercontent.com/$account/$repo/$branch/windows/profile.ps1"
$script:latestVersionFile = [System.IO.Path]::Combine("$HOME",'.latest_profile_version')
$script:versionRegEx      = "# [vV]ersion (?<version>\d+\.\d+\.\d+)"
$script:dotfiles          = [System.IO.Path]::Combine("$HOME","$repo")

function promptProfileUpdate {
  if (isProfileOutdated) {
    $choice = PromptBooleanQuestion "Found newer profile, install" $true
    if ($choice) {
      updateProfile
    }
  }
}

function isProfileOutdated {
  if ([System.IO.File]::Exists($latestVersionFile)) {
    $latestVersion = [System.IO.File]::ReadAllText($latestVersionFile)
    $currentProfile = [System.IO.File]::ReadAllText((Join-Path (Split-Path -parent $profile) "profile.ps1"))
    [version]$currentVersion = "0.0.0"
    if ($currentProfile -match $versionRegEx) {
      $currentVersion = $matches.Version
    }
    Write-Host "Current version: $currentVersion`nLatest version: $latestVersion"
  
    if ([version]$latestVersion -gt $currentVersion) {
      return $true
    }
  }

  $null = Start-ThreadJob -Name "Get remote version" -StreamingHost $Host -ArgumentList $remoteVersionUrl, $latestVersionFile, $versionRegEx -ScriptBlock {
    param ($remoteVersionUrl, $latestVersionFile, $versionRegEx)

    $latestVersion = [System.IO.File]::ReadAllText($latestVersionFile)
    $profileFile = Invoke-WebRequest -Uri $remoteVersionUrl -UseBasicParsing

    [version]$remoteVersion = "0.0.0"
    if ($profileFile -match $versionRegEx) {
      $remoteVersion = $matches.Version
      if ($remoteVersion -gt [version]$latestVersion) {
        Set-Content -Path $latestVersionFile -Value $remoteVersion
      }
    }
  }
  
  $false
}

function updateProfile() {
  if (Test-Path "$dotfiles\.git") {
    $null = Start-ThreadJob -Name "Update profile using git" -StreamingHost $Host -ArgumentList $dotfiles -ScriptBlock {
      param ($dotfiles)
      Set-Location $dotfiles
      [boolean]$stashed = $false
      [string]$stashName = New-Guid
      try {
        $stashed = (git stash push -m $stashName -u)
      } catch {}
      git fetch
      git pull
      . .\windows\scripts\bootstrap.ps1 -install $true;
      try {
        git stash pop $stashName
      } catch {}
    }
  } else {
    . $PSScriptRoot/../setup/remote.ps1 $true
  }
}

$null = promptProfileUpdate