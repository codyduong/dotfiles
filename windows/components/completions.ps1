Get-ChildItem -Path (Join-Path $PSScriptRoot "completions")
| Where-Object { $_.extension -eq ".ps1" }
| Where-Object { $_.Name[0] -ne "." }
| ForEach-Object -process {
  # Invoke-Expression ". '$_'"
  Write-Host "components.$_ : $(Measure-Command { Invoke-Expression ". '$_'" })"
}

# this contains custom completions
Register-CompletionsKomorebic
# Register-CompletionsNpm