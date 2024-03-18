[CmdletBinding(DefaultParametersetName = 'none')] 
param (
  [Parameter(Position = 0, ParameterSetName = "remote")]
  [boolean]
  $isBootstrappingFromRemote,

  [Parameter(Position = 1, ParameterSetName = "remote", mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]
  $sourceFile,

  [Parameter(ParameterSetName = "skip")]
  [switch]
  $update,

  [Parameter(ParameterSetName = "skip")]
  [switch]
  $skip,

  [Parameter(ParameterSetName = "skip")]
  [switch]
  $linux
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

## Setup the custom bootstrap.alias
$script:bootstrapToPrepend = "`$script:pathToBootstrap = `"$PSCommandPath`"`r`n"
$script:bootstrapToRun = "Invoke-Expression `"`$pathToBootstrap -skip:``$`$(`$skip.IsPresent) -update:``$`$(`$update.IsPresent) -linux:``$`$(`$linux.IsPresent)`"`r`n"
$script:bootstrapAlias = Join-Path $aliasesDir "bootstrap.ps1"
$script:bootstrapContent = ($bootstrapToPrepend + (Get-Content -Path $bootstrapAlias -Raw))
$script:bootstrapLines = $bootstrapContent -split "`r`n"
for ($i = $bootstrapLines.Length; $i -ge 0; $i--) {
  if ($bootstrapLines[$i] -match 'BUILD_START') {
    $bootstrapLines[$i] = $bootstrapLines[$i] + "`r`n" + $bootstrapToRun
    break
  }
}
($bootstrapLines -join "`r`n") | Set-Content -Path $bootstrapAlias

## Setup thefuck alias
$script:fuckPath = Join-Path $aliasesDir "fuck.ps1"
thefuck --alias | Set-Content -Path $fuckPath

## Setup oh-my-posh (precompute here to save time)
# https://ohmyposh.dev/docs/configuration/debug-prompt <-- this prompt I never use, so manually disable it
# because we precompute the script file, the call-stack is not empty, thus thinking we are debugging, so just replace
# Saves around 70-100ms
$script:ohMyPoshPath = Join-Path $componentDir "ohmyposh.ps1"
(Invoke-Expression (@"
  $(oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json")
"@ -replace "\|\s*Invoke-Expression",'')
) -replace '\$script:PromptType = \"debug\"',@"
  #`$script:PromptType = `"debug`" # Disabled by bootstrap.ps1
  `$script:PromptType = `"primary`"
"@
| Set-Content -Path $ohMyPoshPath


##############
# Config Files
##############
$script:localFiles = '../.files'

Copy-Item $PSScriptRoot/$localFiles/%USERPROFILE%/* -Recurse -Exclude *.md -Destination $HOME -ErrorAction SilentlyContinue

#############
# Other Files
#############
Copy-Item $PSScriptRoot/$localFiles/%LOCALAPPDATA%/* -Recurse -Exclude *.md -Destination $Env:LOCALAPPDATA -ErrorAction SilentlyContinue

#####
# WSL
#####
if ((wsl --list) -and $linux) {
  $script:dest = Join-Path $PSScriptRoot '/../../linux/home/'
  # Make sure the path is in the correct format for WSL
  $script:fixDest = wsl -e bash -ic "wslpath -u '$dest'"
  Write-Host "<wsl password>" $fixDest
  wsl sudo rsync -av --progress "$fixDest" '~/'
}

}
catch {
  Write-Host $_
}
finally {
# Reload the shell
Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}
