[CmdletBinding(DefaultParametersetName='none')] 
param (
    [Parameter(Position=0, ParameterSetName="remote")][boolean]$isBootstrappingFromRemote,
    [Parameter(Position=1, ParameterSetName="remote", mandatory)][string]$sourceFile,
    [Parameter(Position=0, ParameterSetName="update")][boolean]$update,
    [Parameter(Position=1, ParameterSetName="update")][boolean]$skip
)

. $PSScriptRoot\utils.ps1

$installDeps = $false
if ($isBootstrappingFromRemote -and -not $update) {
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

if ($update) {
  . $PSScriptRoot\install.ps1 $true
} else {
  $installDeps = if ($skip) {$false} else {PromptBooleanQuestion "Would you like to install the required dependencies" $true}
  if ($installDeps) {
    . $PSScriptRoot\install.ps1
  }
}

$script:profileDir = Split-Path -parent $profile
$script:componentDir = Join-Path $profileDir "components"
$script:setupDir = Join-Path $profileDir "setup"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $setupDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path $PSScriptRoot/../*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path $PSScriptRoot/../components/** -Destination $componentDir -Include **
Copy-Item -Path $PSScriptRoot/../setup/remote.ps1 -Destination $setupDir -Include **
# Copy-Item -Path ./home/** -Destination $home -Include **
