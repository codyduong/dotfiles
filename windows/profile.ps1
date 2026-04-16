# version 1.14.1

Push-Location (Split-Path -parent "$profile")
"functions",
"exports",
"components",
"aliases",
"scripts"
| Where-Object { Test-Path "$_.ps1" } | ForEach-Object -process {
  $debug = if ($_ -eq "components" ) {
    "-debug"
  } else {
    ""
  }
  Write-Output "$_ : $(Measure-Command { Invoke-Expression ". .\$_.ps1 $debug" -ErrorAction Continue })"
  # Invoke-Expression ". .\$_.ps1" -ErrorAction Continue
}
Pop-Location

Import-Module alias-tips