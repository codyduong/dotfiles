param (
  [switch]
  $debug
)

Get-ChildItem -Path "./components"
| Where-Object { $_.extension -eq ".ps1" }
| Where-Object { $_.Name[0] -ne "." }
| ForEach-Object -process {
  if ($debug.IsPresent) {
    Write-Output "components.$_ : $(Measure-Command { Invoke-Expression ". '$_' -debug:`$$debug" })"
  }
  else {
    Invoke-Expression ". '$_'"
  }
}

# PS-Readline
Import-Module PSProfiler

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PsFzfOption -TabExpansion
