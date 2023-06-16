function winkey {
  [CmdletBinding(DefaultParametersetName = 'none')]
  param (
    [Parameter(Mandatory, Position = 0)]
    [boolean]
    $enable
  )

  if ($enable) {
    & $PSScriptRoot/.winenable.ps1
  }
  else {
    & $PSScriptRoot/.windisable.ps1
  }
}