Get-ChildItem -Path "./components" | Where-Object { $_.extension -eq ".ps1" } | ForEach-Object -process { Invoke-Expression ". $_" }

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression
try {
  Import-Module PSReadLine
} catch [System.IO.FileLoadException] {}
Import-Module CompletionPredictor
Import-Module Terminal-Icons

# PS-Readline
$PSReadLineOptions = @{
  PredictionSource    = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
}
Set-PSReadLineOption @PSReadLineOptions

# git
Import-Module git-aliases-plus -DisableNameChecking
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  Import-Module Posh-Git -arg 0,0,1
}

# profiling
Import-Module PSProfiler
Import-Module alias-tips