. $PSScriptRoot/.completions.ps1
# Ironically we use npm Get-NpmRun for our Yarn Run completions... it's just easier...
# . $PSScriptRoot/npm.ps1

$script:completions_yarn_export_version = [semver]'0.1.0'
# holy fuck this is slow?
# $script:completions_yarn_version = $(yarn --version).Trim()
$script:completions_yarn_path = (Join-Path $HOME ".completions.yarn")

function Export-CompletionsYarnClixml {
  Param(
    [Parameter()]
    [switch]$PassThru
  )

  $yarnHelp = yarn -h

  $yarn = [ordered]@{}

  # options, commands
  $state = $null

  foreach ($line in $yarnHelp -split "`r?`n") {
    $line = $line.Trim()

    if ($line -match '^Options:') {
      $state = 'options'
      
      continue
    }


    if ($line -match '^Commands:') {
      $state = 'commands'

      continue
    }

    if ($null -eq $state) {
      continue
    }

    if ($state -eq 'options') {
      # we actually redo this in sub commands, so ignore
      # continue
      
      $parts = $line -split ',?\s{2,}'
      # the first part is options, the second part is descriptions
      $options = $parts | Select-Object -First 1

      foreach($option in $options -split ',\s') {
        $option = $option.Trim()

        if ($option -eq '') {
          continue
        }

        $optionParts = $option -split (' ')

        $optionBase = $optionParts | Select-Object -First 1
        $optionArgs = $optionParts | Select-Object -Skip 1

        $optionArgsCompletable = [ordered]@{}
        foreach ($optionArg in $optionArgs) {
          if ($optionArg -match '\[bool\]') {
            $optionArgsCompletable['true'] = $null
            $optionArgsCompletable['false'] = $null
          }
        }

        if ($optionBase.StartsWith('--')) {
          if ($null -eq $yarn['$flags']) {
            $yarn['$flags'] = [ordered]@{}
          }
          $yarn['$flags'][$optionBase] = $optionArgsCompletable
        } elseif ($optionBase.StartsWith('-')) {
          if ($null -eq $yarn['$sflags']) {
            $yarn['$sflags'] = [ordered]@{}
          }
          $yarn['$sflags'][$optionBase] = $optionArgsCompletable
        } else {
          Write-Error "uh oh $option"
        }
      }
    }

    if ($state -eq 'commands') {
      if ([string]::IsNullOrEmpty($line)) {
        $state = $null
        continue
      }

      $line = $line -replace '-\s+', '' -split '/' | Select-Object -First 1

      $yarn[$line] = [ordered]@{}

      # Write-Host $line
      $subflags = (yarn --help $line)

      # options, commands, examples
      $innerState = $null

      # Write-Host $line

      foreach ($innerLine in $subflags -split "`r?`n") {
        $innerLine = $innerLine.Trim()

        if ($innerLine -match '^Options:') {
          $innerState = 'options'
          
          continue
        }

        if ($innerLine -match '^Examples:') {
          $innerState = 'examples'

          continue
        }

        if ($null -eq $innerState) {
          continue
        }

        if ($innerState -eq 'options') {    
          $parts = $innerLine -split ',?\s{2,}'
          # the first part is options, the second part is descriptions
          $options = $parts | Select-Object -First 1
    
          foreach ($option in $options -split ',\s') {
            if ($option -match 'Visit http') {
              break
              $innerState = $null
            }

            $option = $option.Trim()
    
            if ($option -eq '') {
              continue
            }
    
            $optionParts = $option -split (' ')
    
            $optionBase = $optionParts | Select-Object -First 1
            $optionArgs = $optionParts | Select-Object -Skip 1
    
            $optionArgsCompletable = [ordered]@{}
            foreach ($optionArg in $optionArgs) {
              if ($optionArg -match '\[bool\]') {
                $optionArgsCompletable['true'] = $null
                $optionArgsCompletable['false'] = $null
              }
            }

            if ($null -eq $yarn[$line]['$flags']) {
              $yarn[$line]['$flags'] = [ordered]@{}
            }
            if ($null -eq $yarn[$line]['$sflags']) {
              $yarn[$line]['$sflags'] = [ordered]@{}
            }


            if (($yarn['$sflags'].Keys -contains $optionBase) -or ($yarn['$flags'].Keys -contains $optionBase)) {
              continue
            }
    
            if ($optionBase.StartsWith('--')) {
              $yarn[$line]['$flags'][$optionBase] = $optionArgsCompletable
            }
            elseif ($optionBase.StartsWith('-')) {
              $yarn[$line]['$sflags'][$optionBase] = $optionArgsCompletable
            }
            else {
              # Write-Error "uh oh $option"
            }
          }
        }

        if ($innerState -eq 'examples') {
          # this is just taken from npm version 'usage' but we prestrip the leading '$ '
          $innerLine = $innerLine.Trim() -replace '\$\s+'

          if ($innerLine -match 'This command yet to be implemented') {
            continue
          }

          if ([string]::IsNullOrEmpty($innerLine)) {
            $innerState = $null
            continue
          }

          # Write-Host $innerLine
          
          $outerSegments = ($innerLine -replace '\s*\|\s*', '|' -split ' ') | Select-Object -Skip 1
          # ex. "adduser", "install"
          # $base_seg = $outerSegments | Select-Object -First 1
          $curr_segment = $yarn
          $inner = $false
          
          foreach ($outerSegment in $outerSegments) {
            $segments = @($outerSegment)
            # Not a parameter and can be split (notated by |)
            if (-not ($outerSegment.StartsWith('<') -or $outerSegment.EndsWith('>')) -and $outerSegment.Contains('|')) {
              # If it contains a =, we need to create a special case to handle it
              if ($outerSegment.Contains('=')) {
                $special = $outerSegment.Split('=')
                $left = ($special | Select-Object -First 1) + '='
                $right = $special | Select-Object -Skip 1
                $segments = $right.Split('|') | ForEach-Object { $left + $_ }
              }
              else {
                $inner = $true
                $segments = $outerSegment.Split('|')
              }
            }
            
            foreach ($segment in $segments) {
              $segment = $segment.Trim('[', ']', ' ')
          
              if ($null -eq $curr_segment) {
                Write-Error 'uh oh...'
                continue
              }
          
              # handle subcommands
              $this_segment = $(if ($null -ne $curr_segment[$segment]) { $curr_segment[$segment] } else { $null })
              if ($null -eq $this_segment) {
                # create a new node
                $curr_segment[$segment] = [ordered]@{}
                # traverse deeper
                if (-not $inner) {
                  $curr_segment = $curr_segment[$segment]
                }
              }
              elseif (-not $inner) {
                # traverse deeper
                $curr_segment = $this_segment
              }
            }
          }
        }


      }
    }
  }
  
  $toReturn = @{
    export_version         = $script:completions_yarn_export_version.ToString();
    yarn_version           = $script:completions_yarn_version;
    tree                   = $yarn;
  }

  $toReturn | Export-Clixml -Path $script:completions_yarn_path

  if ($PassThru) {
    $toReturn
  }
}

# this is basically the same as Get-CompletionsNpm with npm swapped out for yarn.
# plus we support root level $flags and $sflags
function Get-CompletionsYarn {
  param(
    [Parameter()]
    [string]$string,
  
    # removes last segment if it is partial word or flag
    # then gives all possibles
    [Parameter()]
    [switch]$allPossible
  )

  $string = ($string -replace '^yarn\s+', '').Trim() -replace '\s{1,}', ' '
  $parts = $string -split ' '

  <#
  $last = $parts | Select-Object -Last 1

  if ([String]::IsNullOrEmpty($last)) {
    $last = $parts | Select-Object -Last 1
  }
  #>

  $clixml = $null

  if (-not (Test-Path $script:completions_yarn_path -ErrorAction SilentlyContinue)) {
    $clixml = Export-CompletionsYarnClixml -PassThru
  }

  if ($null -eq $clixml) {
    $clixml = Import-Clixml -Path $script:completions_yarn_path
  }

  $yarn = $clixml.tree

  $base = $parts | Select-Object -First 1
  $2ndlast = $parts[-2]
  $last = $parts | Select-Object -Last 1

  $options = @()
  $allOptions = 
  @(
    try {$yarn['$sflags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  ) + @(
    try {$yarn['$flags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  ) + @(
    try {$yarn[$base]['$sflags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  ) + @(
    try {$yarn[$base]['$flags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  )

  if ($null -ne $2ndlast -and $2ndlast.StartsWith('-')) {
    if ($2ndlast.StartsWith('--')) {
      $options = $yarn[$base]['$flags'][$2ndlast][0]
    } else {
      $options = $yarn[$base]['$sflags'][$2ndlast][0]
    }
  }

  if ($options.Count -gt 0) {
    return $options
  }

  if ($last.StartsWith('-')) {
    $thisFlags = try {$yarn[$base]['$flags'].Keys} catch [System.Management.Automation.RuntimeException] {$()}
    $thisSFlags = try {$yarn[$base]['$sflags'].Keys} catch [System.Management.Automation.RuntimeException] {$()}

    if ($last.StartsWith('--')) {
      $options = $thisFlags
      $options += $yarn['$flags'].Keys
    } else {
      $options = $thisSFlags
      $options += $yarn['$sflags'].Keys
    }

    # Write-Pretty $yarn
    # if we are complete, then don't use it
    if (
      $yarn['$flags'].Keys -contains $last -or
      $yarn['$sflags'].Keys -contains $last -or
      $thisFlags -contains $last -or
      $thisSFlags -contains $last
    ) {
      $options = @()
    } else {
      if (-not $allPossible) {
        return $options | Where-Object {$_ -like "$last*"}
      }
    }
  }

  $GetNpmRunRef = ${function:Get-NpmRun}

  $currently_at = $yarn
  # values evaluated at runtime rather than beforehand
  $evaluated = @()
  $runCompletions = @()

  # get as far as possible in autocomplete tree
  foreach ($part in $parts) {
    $next = try { $currently_at[$part] } catch [System.Management.Automation.RuntimeException] { $null }
    
    if ($null -eq $next) {
      # todo traversal of free-form like <>
      break
    }

    $currently_at = $next
  }

  # if we are at the base level or at run then we can use run completions
  if ($parts.Length -eq 1 -or $last -eq 'run' -or $2ndlast -eq 'run') {
    $runCompletions = & $GetNpmRunRef
    # note that we prepend it to our options array, because I like to prioritize it this way
  }

  # Read through all <.*> values, and parse them according to our helpers
  # foreach ($possible in $currently_at.Keys) {
  #   if ($possible -match "<command>") {
  #     $evaluated += & $GetNpmRunRef
  #   }
  # }

  # attempt to use -like
  $options = $currently_at.Keys 
    | Where-Object {$_ -like "$last*"}
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
    | Sort-Object -Property { $_.Length }

  $options += $evaluated
    | Where-Object {$_ -like "$last*"}

  $runCompletionsMaybe = $runCompletions | Where-Object {$_ -like "$last*"}
  if ($runCompletionsMaybe.Count -gt 0) {
    $options = @($runCompletionsMaybe + $options)
  }

  # if we failed fallback to the tree
  if ($null -eq $options -or $options.Count -eq 0) {
    $options = $currently_at.Keys
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
    | Sort-Object -Property { $_.Length }

    $options += $evaluated
    $options = @($runCompletions + $options)
  }

  $allOptions += $evaluated
  $allOptions += $currently_at.Keys
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
  $allOptions = @($runCompletions + $allOptions)
  
  # remove nullish values
  $allOptions = $allOptions | Where-Object { $null -ne $_ }

  # if we have $withFlags, always append flags regardless of whether we are searching for a flag
  if (-not $allPossible) {
    return $options
  }
  return $allOptions
}

function Register-CompletionsYarn {
  if (-not (Test-Path $script:completions_yarn_path -ErrorAction SilentlyContinue)) {
    Export-CompletionsYarnClixml
  }

  $GetCompletionsYarnRef = ${function:Get-CompletionsYarn}

  Register-ArgumentCompleter -CommandName 'yarn' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $wordToComplete = TrimFzfTrigger $wordToComplete
    $line = $commandAst.ToString()

    if (Get-Module -Name 'PSFzf') {
      $completionTrigger = '**'
      if (-not [string]::IsNullOrWhiteSpace($env:FZF_COMPLETION_TRIGGER)) {
        $completionTrigger = $env:FZF_COMPLETION_TRIGGER
      }
      if ($line.EndsWith($completionTrigger)) {
        $line = $line.Substring(0, $line.Length - $completionTrigger.Length)
        $params = @{string = $line; allPossible = $true}
        $allSuggestions = & $GetCompletionsYarnRef @params
        # return "$allSuggestions"
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

    $params = @{string = $line; allPossible = $false}
    return & $GetCompletionsYarnRef @params
  }.GetNewClosure()
}