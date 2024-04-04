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