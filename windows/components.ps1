Get-ChildItem -Path "./components" | Where-Object { $_.extension -eq ".ps1" } | ForEach-Object -process {
  # Invoke-Expression ". '$_'"
  Write-Host "components.$_ : $(Measure-Command { Invoke-Expression ". '$_'" })"
}

# oh-my-posh
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression
try {
  Import-Module PSReadLine
}
catch [System.IO.FileLoadException] {}
Import-Module CompletionPredictor
# Terminal-Icons is slow! https://github.com/devblackops/Terminal-Icons/issues/76#issuecomment-1147675907
# Use our own fork
$script:TerminalIconsForkPath = (Join-Path $env:USERPROFILE "Terminal-Icons")
if (Test-Path -Path $TerminalIconsForkPath -PathType Container) {
  $script:TerminalIconsVersion = (Import-PowerShellDataFile (Join-Path $TerminalIconsForkPath "Terminal-Icons/Terminal-Icons.psd1")).ModuleVersion
  $script:TerminalIconsModulePath = (Join-Path $TerminalIconsForkPath "Output/Terminal-Icons/$TerminalIconsVersion/Terminal-Icons.psd1")
  # ~250ms here
  # Write-Host $(Measure-Command {Import-Module $TerminalIconsModulePath)
  Import-Module $TerminalIconsModulePath
}
else {
  # ~500ms here
  Import-Module Terminal-Icons
}

# PS-Readline
$PSReadLineOptions = @{
  PredictionSource    = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
}
Set-PSReadLineOption @PSReadLineOptions

# git
Import-Module git-aliases-plus -DisableNameChecking
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  # 0.2 seconds? TODO @codyduong
  Import-Module Posh-Git -arg 0, 0, 1
}

Import-Module PSProfiler
### To save on initial profile load time we will not regenerate the AliasHash. Run only after profile updates?
# Import-Module C:\Users\duong\powershell-essentials\powershell-alias-tips\src\alias-tips.psm1 -ArgumentList 0,0,1 # Development alias-tips load
Import-Module alias-tips
