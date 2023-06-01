$AutoHotkeyDir = $(Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\AutoHotkey" -Name "InstallDir").InstallDir
$AutoHotkeyVersion = $(Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\AutoHotkey" -Name "Version").Version
$Bits = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }
$TestPath = "$AutoHotkeyDir\v2\AutoHotkey$Bits.exe"
$ExecutablePath = if (Test-Path $TestPath) {
  $TestPath
}
else {
  $false
}

function ahk() {
  [CmdletBinding(DefaultParametersetName = 'none')] 
  param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Version,
    [Parameter(Mandatory, position=0, ValueFromRemainingArguments)]$Remaining
  )

  $GettingVersion = if ($Version) {
    $Version
  }
  else {
    "--version" -in $Remaining
  }

  if ($GettingVersion) {
    $AutoHotkeyVersion
  } else {
    if ($ExecutablePath) {
      Start-Process $ExecutablePath -ArgumentList $($Remaining + $MyInvocation.UnboundArguments)
    } else {
      Write-Warning Failed to find AutoHotkey at $TestPath
    }
  }
}