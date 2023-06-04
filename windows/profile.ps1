# version 1.8.0

Push-Location (Split-Path -parent "$profile")
"components",
"functions",
"aliases",
"exports"
| Where-Object { Test-Path "$_.ps1" } | ForEach-Object -process {
  Write-Host "$_ : $(Measure-Command { Invoke-Expression ". .\$_.ps1" })"
}
Pop-Location