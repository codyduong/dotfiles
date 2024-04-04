# Registers tab completions for komorebic
. $PSScriptRoot/.TrimFzfTrigger.ps1

function Register-CompletionsKomorebic {
  if (-not (Test-Path (Join-Path $HOME ".completions.komorebic") -ErrorAction SilentlyContinue)) {
    Export-CompletionsKomorebicClixml
  }

  # Run komorebic help and capture the output
  $clixml = Import-Clixml -Path (Join-Path $HOME ".completions.komorebic")

  $primary_cmds = $clixml.primary_cmds
  $primary_single = $clixml.primary_single
  $primary_double = $clixml.primary_double
  $primary_to_secondaries = $clixml.primary_to_secondaries

  # Register a completer for komorebic commands
  Register-ArgumentCompleter -CommandName 'komorebic' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    # Remove ** or leading PSFzf trigger
    $wordToCompleteTrim = TrimFzfTrigger $wordToComplete

    $segments = $commandAst.ToString() -split ' ' | Where-Object { -not [string]::IsNullOrEmpty($_.Trim()) }

    $isSingle = $wordToComplete -like "-*"
    $isDouble = $wordToComplete -like "--*"

    $suggestions = @()

    # ex. "komorebi"
    if ($segments.Count -eq 1 -and [string]::IsNullOrWhiteSpace($wordToCompleteTrim)) {
      $primary_cmds |
      ForEach-Object { $suggestions += $_ }
    }
    
    if ($segments.Count -ge 2) {
      $current_arg = $()
      try {
        $subcmd = $segments[1]
        $secondary = $primary_to_secondaries[$subcmd]
    
        $secondary_double = $secondary.double | Where-Object { $segments -notcontains $_ }
        $secondary_single = $secondary.single | Where-Object { $segments -notcontains $_ }

        $current_arg = $secondary.arguments[0]
      }
      catch {}

      # ex. "komorebic que", "komorebic -h", "komorebic --h", "komorebic query"
      if ($segments.Count -eq 2) {
        if ($isDouble) {
          $primary_double 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }
          | ForEach-Object { $suggestions += $_ }
          
        }
        elseif ($isSingle) {
          $primary_single 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }
          | ForEach-Object { $suggestions += $_ }
          
        }
        # if we havent completed a subcommand, then we aren't ready for anything but a subcommand
        elseif ($subcmd -notin $primary_cmds) {
          $primary_cmds
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }
          | ForEach-Object { $suggestions += $_ }
        }
        # for complete ones, ex. "komorebic query"
        # if possible use autocomplete on non dash arguments (ie we must have enums)
        elseif ($current_arg -and [string]::IsNullOrWhiteSpace($wordToCompleteTrim)) {
          $current_arg | ForEach-Object { $suggestions += $_ }
        }
      }

      if ($segments.Count -ge 3) {
        $current_arg = $secondary.arguments[$segments.Count - 3]

        if ($isDouble) {
          $secondary_double 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }
          | ForEach-Object { $suggestions += $_ }
          
        }
        elseif ($isSingle) {
          $secondary_single 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }
          | ForEach-Object { $suggestions += $_ }
          
        }
        # if we have an empty space use a completion if available
        elseif ([string]::IsNullOrWhiteSpace($wordToCompleteTrim)) {
          $secondary.arguments[$segments.Count - 2]
          | ForEach-Object { $suggestions += $_ }
        }
        else {
          $current_arg
          | Where-Object { "$_" -like "$wordToCompleteTrim*" -and -not [string]::IsNullOrWhiteSpace($wordToCompleteTrim) }
          | ForEach-Object { $suggestions += $_ }
        }
      }
    }

    # Support for PSFzf
    if (Get-Module -Name 'PSFzf') {
      $completionTrigger = '**'
      if (-not [string]::IsNullOrWhiteSpace($env:FZF_COMPLETION_TRIGGER)) {
        $completionTrigger = $env:FZF_COMPLETION_TRIGGER
      }
      if ($wordToComplete.EndsWith($completionTrigger)) {
        $wordToComplete = $wordToComplete.Substring(0, $wordToComplete.Length - $completionTrigger.Length)
        if ($suggestions.Count -gt 0) {
          # if we have suggestions
          return $suggestions | Invoke-Fzf -Multi
        }
        else {
          # use default fuzzy
          return Invoke-Fzf -Multi
        }
      }
    }
    $suggestions | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'Command', $_) }
    # End Support for PSFzf
  }.GetNewClosure()
}

