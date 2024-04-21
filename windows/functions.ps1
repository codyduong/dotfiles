Get-ChildItem -Path "$PSScriptRoot/functions"
| Where-Object { $_.extension -eq ".ps1" }
| ForEach-Object -process { Invoke-Expression ". '$_'" }
