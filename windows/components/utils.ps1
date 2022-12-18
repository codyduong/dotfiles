
function PromptBooleanQuestion {
  param (
      [parameter(mandatory)][string]$promptStr,
      [boolean]$default
  )
  
  $answer = $null
  $defaultStr = ("y/n")
  if ($null -ne $default) {
      $defaultStr = $default ? "Y/n" : "y/N"
  }
  while ($null -eq $answer) {
      $prompt = Read-Host "$($promptStr) ($($defaultStr))?"
      try {
          $answer = $prompt -match "[yYnN]" ? $prompt -match "[yY]" : $null
      }
      catch {
          
      }
      if ($null -eq $answer) {
          if ($null -ne $default) {
              $answer = $default
              break
          }
          Write-Host "Invalid input, received: " -ForegroundColor "Red" -NoNewline
          Write-Host "$($prompt)"
          Write-Host "`texpected one of: " -ForegroundColor "Red" -NoNewline
          Write-Host 'y', 'Y', 'n', 'N'
      }
  }
  return $answer
}