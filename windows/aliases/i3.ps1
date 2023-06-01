function i3 {
  [CmdletBinding(DefaultParametersetName = 'none')] 
  param (
    [Parameter()]
    [boolean]
    $start,
    [Parameter(position = 0, ValueFromRemainingArguments)]$Remaining = @("start")
  )

  if ("start" -in $Remaining) {
    komorebic start -a
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