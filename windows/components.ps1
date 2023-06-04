Get-ChildItem -Path "./components" | Where-Object { $_.extension -eq ".ps1" } | ForEach-Object -process { Invoke-Expression ". '$_'" }

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression
try {
  Write-Host $(Measure-Command { Import-Module PSReadLine })
}
catch [System.IO.FileLoadException] {}
Write-Host $(Measure-Command { Import-Module CompletionPredictor } )
# Terminal-Icons is slow! https://github.com/devblackops/Terminal-Icons/issues/76#issuecomment-1147675907
Write-Host $(Measure-Command { Import-Module Terminal-Icons } )

# PS-Readline
$PSReadLineOptions = @{
  PredictionSource    = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
}
Write-Host $(Measure-Command { Set-PSReadLineOption @PSReadLineOptions })

# git
Write-Host $(Measure-Command { Import-Module git-aliases-plus -DisableNameChecking })
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  Write-Host $(Measure-Command { Import-Module Posh-Git -arg 0, 0, 1 })
}

Write-Host $(Measure-Command { Import-Module PSProfiler })
### To save on initial profile load time we will not regenerate the AliasHash. Run only after profile updates?
# Import-Module C:\Users\duong\powershell-essentials\powershell-alias-tips\src\alias-tips.psm1 -ArgumentList 0,0,1 # Development alias-tips load
Write-Host $(Measure-Command { Import-Module alias-tips -ArgumentList 0, 0, 0 })