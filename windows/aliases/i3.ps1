function i3 {
  [CmdletBinding(DefaultParametersetName = 'none')]
  param (
    [Parameter()]
    [boolean]
    $start,
    [Parameter(position = 0, ValueFromRemainingArguments)]$Remaining = @("start")
  )

  if ("start" -in $Remaining) {
    $ver = [semver](komorebic --version | Select-String -Pattern '\d+\.\d+\.\d+').Matches[0].Value
    # if ($ver -ge [semver]"0.1.30") {
    #   komorebic start --masir
    # } else {
    #   komorebic start --ffm
    # }
    komorebic start --ffm
    # load config
    & $(Join-Path $HOME '.config/komorebi/komorebi.ps1')
  }
  elseif ("reload" -in $Remaining) {
    # load config
    & $(Join-Path $HOME '.config/komorebi/komorebi.ps1')
  }
  else {
    komorebic @Remaining
  }
}