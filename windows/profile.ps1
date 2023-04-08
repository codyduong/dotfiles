# version 1.6.0

Push-Location (Split-Path -parent $profile)
"components",
"functions",
"aliases",
"exports"
| Where-Object { Test-Path "$_.ps1" } | ForEach-Object -process { Invoke-Expression ". .\$_.ps1" }
Pop-Location