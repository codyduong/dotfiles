# These components will be loaded for all PowerShell instances

Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
. .\console.ps1
. .\gitAlias.ps1
. .\poshGit.ps1
. .\poshGAliasTabCompletion.ps1

Pop-Location