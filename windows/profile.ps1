# version 1.11.0

Push-Location (Split-Path -parent "$profile")
"functions",
"exports",
"components",
"aliases"
# "scripts"
| Where-Object { Test-Path "$_.ps1" } | ForEach-Object -process {
  Write-Output "$_ : $(Measure-Command { Invoke-Expression ". .\$_.ps1" })"
}
Pop-Location
