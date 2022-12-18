[CmdletBinding(DefaultParametersetName='none')] 
param (
    [Parameter(Position=0, ParameterSetName="remote")][boolean]$isBootstrappingFromRemote,
    [Parameter(Position=1, ParameterSetName="remote", mandatory)][string]$sourceFile,
    [Parameter(Position=2, ParameterSetName="install")][boolean]$update
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
  $installDeps = PromptBooleanQuestion "Would you like to install the required dependencies" $true
  if ($installDeps) {
    . $PSScriptRoot\install.ps1
  }
}

$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path $PSScriptRoot/../*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path $PSScriptRoot/../components/** -Destination $componentDir -Include **
# Copy-Item -Path ./home/** -Destination $home -Include **

Remove-Variable componentDir
Remove-Variable profileDir