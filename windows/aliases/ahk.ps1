$script:AHKdir = $false
$script:AHKver = "0.0.0"


$script:AHKRegistryDir0 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey"
$script:AHKRegistryDir1 = "Registry::HKEY_CURRENT_USER\SOFTWARE\AutoHotkey"
try {
  if (Test-Path -Path $AHKRegistryDir0) {
    $script:AHKdir = $(Get-ItemProperty -Path $AHKRegistryDir0 -Name "InstallDir" -ErrorAction Stop).InstallDir
    $script:AHKver = $(Get-ItemProperty -Path $AHKRegistryDir0 -Name "Version" -ErrorAction Stop).Version
  }
  if (Test-Path -Path $AHKRegistryDir1) {
    $script:AHKdir = $(Get-ItemProperty -Path $AHKRegistryDir1 -Name "InstallDir" -ErrorAction Stop).InstallDir
    $script:AHKver = $(Get-ItemProperty -Path $AHKRegistryDir1 -Name "Version" -ErrorAction Stop).Version
  }
}
catch [System.ArgumentException] {}
Remove-Variable AHKRegistryDir0
Remove-Variable AHKRegistryDir1


$script:AHKExecutablePath = "$AHKdir\v2\AutoHotkey$(if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }).exe"
$script:AHKExecutablePathIsValid = Test-Path $AHKExecutablePath
Remove-Variable AHKdir


function ahk() {
  [CmdletBinding(DefaultParametersetName = 'none')]
  param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Version,
    [Parameter(Mandatory, position = 0, ValueFromRemainingArguments)]$Remaining
  )

  $GettingVersion = if ($Version) {
    $Version
  }
  else {
    "--version" -in $Remaining
  }

  if ($GettingVersion) {
    $AHKver
  }
  else {
    if ($AHKExecutablePathIsValid) {
      Start-Process $AHKExecutablePath -ArgumentList $($Remaining + $MyInvocation.UnboundArguments)
    }
    else {
      Write-Warning -Message "Failed to find AutoHotkey at $AHKExecutablePath"
      exit 1
    }
  }
}