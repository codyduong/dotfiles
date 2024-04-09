# Registers tab completions for komorebic
. $PSScriptRoot/.TrimFzfTrigger.ps1

$script:export_version = [semver]'0.1.0'
$script:komorebic_version = $($(komorebic --version | Out-String) -replace 'komorebic','').Trim()

function Export-CompletionsKomorebicClixml {
  Param(
    [Parameter()]
    [switch]$PassThru
  )

  $komorebicHelp = komorebic help
  
  # Define regex patterns to match commands and options
  $commandPattern = '^\s{2}(?<command>\w[\w-]+)'
  $optionPattern = '^Options:\s*$'
  
  # Flags to help with parsing
  $readCommands = $true
  $primary_cmds = @()
  $primary_single = @()
  $primary_double = @()
  # hashmap of primary_cmd -> @{ arguments: singles: }
  $primary_to_secondaries = @{}

  # Parse the output line by line
  foreach ($line in $komorebicHelp -split "`r`n") {
    if ($line.Trim() -eq '') {
      continue
    }

    if ($line -match $optionPattern) {
      $readCommands = $false
      continue
    }

    if ($readCommands) {
      if ($line -match $commandPattern) {
        $primary_cmds += $matches['command']
      }
      continue
    }

    if ($line -match '-([^\W-]+)') {
      $primary_single += $matches[0]
    }
    if ($line -match '--(\w+)') {
      $primary_double += $matches[0]
    }
  }

  foreach ($cmd in $primary_cmds) {
    if ($cmd -like "*Help*") {
      continue
    }

    $subcmdHelp = komorebic $cmd --help

    $arguments = [ordered]@{}
    $this_single = @()
    $this_double = @()

    # Extract the arguments line
    $usageLine = $subcmdHelp -split "`r`n" | Where-Object { $_ -match 'Usage:' }

    # Extract arguments from the usage line
    if ($usageLine -match '<.+?>') {
      # Extract arguments from the usage line and ensure output is always treated as an array
      $argNames = @([regex]::Matches($usageLine, '<(.*?)>') | ForEach-Object {
          $_.Groups[1].Value
        })
  
      # Initialize all arguments with a default value of $null in the hashtable
      foreach ($arg in $argNames) {
        $arguments[$arg.Trim()] = $null
      }
    }

    # Extract possible values for arguments, if any
    $readArguments = $true
    foreach ($line in $subcmdHelp -split "`r`n") {
      if ($line.Trim() -eq '') {
        continue
      }

      if ($line -match $optionPattern) {
        $readArguments = $false
        continue
      }

      if ($readArguments) {
        if ($line -match '\[possible values:') {
          $argName, $possibleValues = $line -split '\[possible values:', 2
          $argName = $argName.Trim('<', '>', ' ').Trim()
          $possibleValues = $possibleValues.Trim('[', ']', ' ').Split(',').Trim()
          $arguments[$argName] = $possibleValues
        }
        continue
      }
      
      if ($line -match '-([^\W-]+)') {
        $this_single += $matches[0]
      }
      if ($line -match '--(\w+)') {
        $this_double += $matches[0]
      }
    }

    # Write-Host $cmd $arguments
    
    $primary_to_secondaries[$cmd] = @{
      arguments = $arguments
      single    = $this_single
      double    = $this_double
    }
  }`

  $toReturn = @{
    export_version         = $script:export_version.ToString();
    komorebic_version      = $script:komorebic_version;
    primary_cmds           = $primary_cmds;
    primary_single         = $primary_single;
    primary_double         = $primary_double;
    primary_to_secondaries = $primary_to_secondaries;
  }

  $toReturn | Export-Clixml -Path (Join-Path $HOME ".completions.komorebic")

  if ($PassThru) {
    $toReturn
  }
}

function Register-CompletionsKomorebic {
  $clixml = $null

  if (-not (Test-Path (Join-Path $HOME ".completions.komorebic") -ErrorAction SilentlyContinue)) {
    $clixml = Export-CompletionsKomorebicClixml -PassThru
  }

  if ($null -eq $clixml) {
    $clixml = Import-Clixml -Path (Join-Path $HOME ".completions.komorebic")
  }

  [semver]$clixml_export_version = if ($null -ne $clixml.export_version) { [semver]($clixml.export_version) } else { [semver]'0.0.0' }
  [semver]$clixml_komorebic_version = if ($null -ne $clixml.komorebic_version) { [semver]($clixml.komorebic_version) } else { [semver]'0.0.0' }
  if (
    $clixml_export_version -lt $script:export_version -or 
    $clixml_komorebic_version -ne $script:komorebic_version) {
    Write-Host "$clixml_export_version, $script:export_version, $clixml_komorebic_version, $script:komorebic_version"
    $clixml = Export-CompletionsKomorebicClixml -PassThru
  }

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
    $allSuggestions = @()

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
          $suggestions += $primary_double 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $primary_cmds + $primary_double + $primary_single
        }
        elseif ($isSingle) {
          $suggestions += $primary_single 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $primary_cmds + $primary_double + $primary_single
        }
        # if we havent completed a subcommand, then we aren't ready for anything but a subcommand
        elseif ($subcmd -notin $primary_cmds) {
          $suggestions += $primary_cmds
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $primary_cmds + $primary_double + $primary_single
        }
        # for complete ones, ex. "komorebic query"
        # if possible use autocomplete on non dash arguments (ie we must have enums)
        elseif ($current_arg -and [string]::IsNullOrWhiteSpace($wordToCompleteTrim)) {
          $suggestions += $current_arg

          $allSuggestions += $current_arg + $secondary_double + $secondary_single
        }
      }

      if ($segments.Count -ge 3) {
        $current_arg = $secondary.arguments[$segments.Count - 3]

        if ($isDouble) {
          $suggestions += $secondary_double 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $current_arg + $secondary_double + $secondary_single
        }
        elseif ($isSingle) {
          $suggestions += $secondary_single 
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $current_arg + $secondary_double + $secondary_single
        }
        # if we have an empty space use a completion if available
        elseif ([string]::IsNullOrWhiteSpace($wordToCompleteTrim)) {
          $suggestions += $secondary.arguments[$segments.Count - 2]

          $allSuggestions += $secondary.arguments[$segments.Count - 2] + $secondary_double + $secondary_single
        }
        else {
          $suggestions += $current_arg
          | Where-Object { "$_" -like "$wordToCompleteTrim*" }

          $allSuggestions += $current_arg + $secondary_double + $secondary_single
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
        if ($allSuggestions.Count -gt 0) {
          # if we have suggestions
          $used = $allSuggestions | Invoke-Fzf -Multi -Query $wordToComplete
          if ($null -ne $used) {
            return $used
          }
          return $wordToComplete
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

