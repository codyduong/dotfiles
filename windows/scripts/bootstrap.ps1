param (
    [Parameter(ParameterSetName="remote")][boolean]$isBootstrappingFromRemote,
    [Parameter(ParameterSetName="remote", mandatory)][string]$sourceFile
)

. $PSScriptRoot\utils.ps1

$installDeps = $false
if ($isBootstrappingFromRemote) {
  $installLocalCopy = PromptBooleanQuestion @"

It seems like you are installing directly from remote,
would you like to create a local git repository to
track updates and boostrap new profiles from
"@ $true
  if ($installLocalCopy) {
    Write-Host "`n`tExtracting $($sourceFile) to 'This Pc\\Documents'" -ForegroundColor DarkGray
    
    Read-File $sourceFile [Environment]::GetFolderPath("MyDocuments")
  }
}

$installDeps = PromptBooleanQuestion "`nWould you like to install the required dependencies" $true
if ($installDeps) {
  . $PSScriptRoot\install.ps1
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