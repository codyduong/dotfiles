. $PSScriptRoot\utils.ps1
$script:account = "codyduong"
$script:repo = "Dotfiles"
$script:branch = "main"
$script:DotfilesRemoteProfileUrl = "https://raw.githubusercontent.com/$account/$repo/$branch/windows/profile.ps1"
$script:DotfilesAvailableProfileVersionFile = [System.IO.Path]::Combine("$HOME", '.latest_profile_version')
$script:VersionRegEx = "# [vV]ersion (?<version>\d+\.\d+\.\d+)"
$script:Dotfiles = [System.IO.Path]::Combine("$HOME", "$repo")
Remove-Variable account
Remove-Variable repo
Remove-Variable branch

function Write-ProfileVersionsToHost {
  "Current: $DotfilesProfileCurrentVersion    Available: $DotfilesAvailableProfileVersion"
}

function Sync-Profile {
  if (Get-ProfileUpdateAvailable) {
    $choice = PromptBooleanQuestion "Profile update available $DotfilesProfileCurrentVersion -> $DotfilesAvailableProfileVersion, install" $true
    if ($choice) {
      Update-Profile
    }
  }
  else {
    # Write-Host "Powershell Profile $DotfilesProfileCurrentVersion ($(Join-Path (Split-Path -parent $profile) "profile.ps1"))" 
  }
}

function Update-AvailableProfile {
  param(
    [switch]$Force
  )

  $ArgsToPassToThreadJob = @(
    $DotfilesRemoteProfileUrl,
    $DotfilesAvailableProfileVersionFile,
    $VersionRegEx,
    $Dotfiles
  )

  $existingJob = Get-Job -Name "Get remote version" -ErrorAction SilentlyContinue

  $startJob = $true
  if ($Force -and ($null -ne $existingJob)) {
    Remove-Job -Job $existingJob -Force
  }
  else {
    if ($null -ne $existingJob) { 
      $lastRunTime = $existingJob.PSBeginTime
      $currentTime = Get-Date
      $timeDifference = $currentTime - $lastRunTime

      if ($timeDifference.TotalMinutes -gt 30) {
        Remove-Job -Job $existingJob -Force
      }
      else {
        $startJob = $false
      }
    }
  }

  if ($startJob) {
    $null = Start-Job -Name "Get remote version" -ArgumentList $ArgsToPassToThreadJob -ScriptBlock {
      param ($DotfilesRemoteProfileUrl, $DotfilesAvailableProfileVersionFile, $VersionRegEx, $Dotfiles)

      $DotfilesAvailableProfileVersion = [System.IO.File]::ReadAllText($DotfilesAvailableProfileVersionFile)

      if (Test-Path "$Dotfiles\.git") {
        Set-Location $Dotfiles
        $stashed = $false
        [string]$stashName = New-Guid
        try {
          $stashed = $(git stash push -u -m $stashName)
        }
        catch {
          Write-Warning $_
        }
        $old_branch = $(git rev-parse --abbrev-ref HEAD)
        git checkout $branch
        git fetch
        git pull
        $profileFile = [System.IO.File]::ReadAllText("$Dotfiles\windows\profile.ps1")
        git checkout $old_branch
        if ($stashed -ne $false) {
          git stash pop
        }
      }
      else {
        # Check via remote if we can
        $profileFile = Invoke-WebRequest -Uri $DotfilesRemoteProfileUrl -UseBasicParsing
      }
      [version]$remoteVersion = "0.0.0"
      if ($profileFile -match $VersionRegEx) {
        $remoteVersion = $matches.Version
        if ($remoteVersion -gt [version]$DotfilesAvailableProfileVersion) {
          Set-Content -Path $DotfilesAvailableProfileVersionFile -Value $remoteVersion
        }
      }
    }
  }
}

function Get-ProfileUpdateAvailable {
  [boolean]$isOutdated = $false
  if ([System.IO.File]::Exists($DotfilesAvailableProfileVersionFile)) {
    $global:DotfilesAvailableProfileVersion = [version][System.IO.File]::ReadAllText($DotfilesAvailableProfileVersionFile)
    $global:currentProfile = [System.IO.File]::ReadAllText((Join-Path (Split-Path -parent "$profile") "profile.ps1"))
    [version]$global:DotfilesProfileCurrentVersion = "0.0.0"
    if ($currentProfile -match $versionRegEx) {
      $global:DotfilesProfileCurrentVersion = $matches.Version
    }
    if ([version]$DotfilesAvailableProfileVersion -gt $DotfilesProfileCurrentVersion) {
      $isOutdated = $true
    }
  }

  Update-AvailableProfile
  
  $isOutdated
}

function Update-Profile {
  try {
    if (Test-Path "$Dotfiles\.git") {
      $old_location = Get-Location
      Set-Location $Dotfiles
      $stashed = $false
      [string]$stashName = New-Guid
      try {
        $stashed = $(git stash push -u -m $stashName)
      }
      catch {
        Write-Warning $_
      }
      $old_branch = $(git rev-parse --abbrev-ref HEAD)
      git checkout $branch
      git fetch
      git pull
      . .\windows\scripts\bootstrap.ps1 -update;
      git checkout $old_branch
      if ($stashed -ne $false) {
        git stash apply stash^{/$stashName}
      }
    }
    else {
      . $PSScriptRoot/../setup/remote.ps1 $true
      Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
    }
  }
  finally {
    Invoke-Command { & "pwsh.exe" -NoLogo -command "& Set-Location $old_location" } -NoNewScope
  }
}


Remove-Variable $VersionRegEx


# $null = Sync-Profile