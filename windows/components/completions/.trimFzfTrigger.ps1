# https://github.com/kelleyma49/PSFzf/blob/cba20d2c08619354f1022360c811cd48d3e8b451/PSFzf.TabExpansion.ps1#L111C1-L123C2
function TrimFzfTrigger {
  # param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition, $action)
  param ($wordToComplete)
  if ([string]::IsNullOrWhiteSpace($env:FZF_COMPLETION_TRIGGER)) {
    $completionTrigger = '**'
  }
  else {
    $completionTrigger = $env:FZF_COMPLETION_TRIGGER
  }
  if ($wordToComplete.EndsWith($completionTrigger)) {
    $wordToComplete = $wordToComplete.Substring(0, $wordToComplete.Length - $completionTrigger.Length)
  }
  $wordToComplete
}