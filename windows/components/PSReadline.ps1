try {
  Import-Module PSReadLine
}
catch [System.IO.FileLoadException] {}
Import-Module CompletionPredictor

$PSReadLineOptions = @{
  PredictionSource    = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
}
Set-PSReadLineOption @PSReadLineOptions
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
