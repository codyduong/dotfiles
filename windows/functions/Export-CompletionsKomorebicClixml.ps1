function Export-CompletionsKomorebicClixml {
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

  @{
    primary_cmds = $primary_cmds;
    primary_single = $primary_single;
    primary_double = $primary_double;
    primary_to_secondaries =  $primary_to_secondaries;
  } | Export-Clixml -Path (Join-Path $HOME ".completions.komorebic")
}