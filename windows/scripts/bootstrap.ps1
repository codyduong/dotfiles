[CmdletBinding(DefaultParametersetName = 'none')] 
param (
  [Parameter(Position = 0, ParameterSetName = "remote")]
  [boolean]
  $isBootstrappingFromRemote,

  [Parameter(Position = 1, ParameterSetName = "remote", mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]
  $sourceFile,

  [Parameter(ParameterSetName = "update")]
  [switch]
  $update,

  [Parameter(ParameterSetName = "skip")]
  [switch]
  $skip
)

try {
. $PSScriptRoot\utils.ps1

$installDeps = $false
if ($isBootstrappingFromRemote -and -not $update.IsPresent) {
  $installLocalCopy = PromptBooleanQuestion @"

It seems like you are installing directly from remote,
would you like to create a local git repository to
track updates and boostrap new profiles from
"@ $true
  if ($installLocalCopy) {
    Write-Host "`n`tExtracting $($sourceFile) to '$HOME'" -ForegroundColor DarkGray
    
    Read-File $sourceFile $HOME
  }
}

if ($update.IsPresent) {
  . $PSScriptRoot\install.ps1 -update
}
else {
  $installDeps = if ($skip.IsPresent) { $false } else { PromptBooleanQuestion "Would you like to install the required dependencies" $true }
  if ($installDeps) {
    . $PSScriptRoot\install.ps1
  }
}

function script:createDir {
  New-Item $args -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
}
####################
# Powershell Profile
####################
$script:profileDir = Split-Path -parent $profile
$script:aliasesDir = Join-Path $profileDir "aliases"
$script:componentDir = Join-Path $profileDir "components"
$script:setupDir = Join-Path $profileDir "setup"

Remove-Item $aliasesDir -Recurse -ErrorAction SilentlyContinue
Remove-Item $componentDir -Recurse -ErrorAction SilentlyContinue

createDir $profileDir
createDir $aliasesDir
createDir $componentDir
createDir $setupDir

Copy-Item -Path $PSScriptRoot/../*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path $PSScriptRoot/../aliases/** -Destination $aliasesDir -Include **
Copy-Item -Path $PSScriptRoot/../components/** -Destination $componentDir -Include **
Copy-Item -Path $PSScriptRoot/../setup/remote.ps1 -Destination $setupDir -Include **
# Copy-Item -Path ./home/** -Destination $home -Include **

##############
# Config Files
##############
$script:localFiles = '../.files'

Copy-Item $PSScriptRoot/$localFiles/%USERPROFILE%/* -Recurse -Exclude *.md -Destination $HOME -ErrorAction SilentlyContinue

#############
# Other Files
#############
Copy-Item $PSScriptRoot/$localFiles/%LOCALAPPDATA%/* -Recurse -Exclude *.md -Destination $Env:LOCALAPPDATA -ErrorAction SilentlyContinue

}
catch {
  Write-Host $_
}
finally {
# Reload the shell
Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}