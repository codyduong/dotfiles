. $PSScriptRoot/.TrimFzfTrigger.ps1

$script:export_version = [semver]'0.1.0'
$script:npm_version = $($(komorebic --version | Out-String) -replace 'komorebic','').Trim()
$script:path = (Join-Path $HOME ".completions.npm")

function Write-Pretty {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]$InputObject
  )

  Process {
    # This function prints the structure
    function Write-PrettyR {
      param (
        [object]$Obj,
        [int]$Level = 0
      )

      $indentation = " " * ($Level * 4) # 4 spaces per indentation level
      if ($Obj -is [System.Collections.IDictionary]) {
        foreach ($key in $Obj.Keys) {
          $value = $Obj[$key]
          if ($null -eq $value) {
            Write-Host "${indentation}$key = $null"
          }
          elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            Write-Host "${indentation}$key = ,@"
            Write-PrettyR -Obj $value -Level ($Level + 1)
          }
          else {
            Write-Host "${indentation}$key = $value"
          }
        }
      }
      elseif ($Obj -is [System.Collections.IEnumerable] -and -not ($Obj -is [string])) {
        foreach ($item in $Obj) {
          Write-PrettyR -Obj $item -Level $Level
        }
      }
      else {
        Write-Host "${indentation}$Obj"
      }
    }

    # Call the recursive function with the current pipeline object
    Write-PrettyR -Obj $InputObject
  }
}

function Export-CompletionsNpmClixml {
  Param(
    [Parameter()]
    [switch]$PassThru
  )

  $npmHelp = npm -l

  # $testmatchers = [ordered]@{
  #   access = ,@('access', [ordered]@{
  #       list = @('list', [ordered]@{
  #         'packages' = @('packages', [ordered]@{
  #           '<user>|<scope>|<scope:team>' = $null
  #           '<package>' = $null
  #         });
  #         'collaborators' = @('collaborators', [ordered]@{

  #         })
  #       });
  #       get = ,@('get', [ordered]@{
  #         'status' = @('status', [ordered]@{
  #           '<package>' = $null
  #         })
  #       });
  #       set = ,@('set', [ordered]@{
  #         'status=' = @('status=', [ordered]@{
  #           'public' = @('public', [ordered]@{
  #             '<package>' = $null
  #           })
  #         })
  #       })
  #     }
  #   );
    
    
  # }

  <#
  $segmentsPrev = @('npm', 'access', 'list', 'packages') # 1 1 1 1
  $segmentsInput = 'access list packages'
  $segmentsNow = @('npm', 'access', 'list', 'collaborators') # 2 2 2 1
  $segmentsNow = @('npm', 'access', 'get', 'status') # 3 3 1 1
  $segmentsNow = @('npm', 'access', 'set', 'status=public|private') # 4 4 1 1
  $segmentsNow = @('npm', 'access', 'set', 'mfa=none|publish|automation') # 5 5 2 1
  #>

  $npm = [ordered]@{}

  # 'all'
  # 'usageNew'
  #   'usageSeen'
  # 'options'
  $state = $null

  # Gets package.json and reads scripts key
  foreach ($line in $npmHelp -split "`r`n") {
    $line = $line.Trim()

    if ([string]::IsNullOrEmpty($line)) {
      if ($state -eq 'usage' -or $state -eq 'options') {
        # reset the state to ready if we have a break
        $state = 'ready'
      }
      continue
    }

    if ($line -match '^All commands:') {
      $state = 'ready'
    }

    if ($null -eq $state) {
      continue
    }

    if ($line -match '^Usage:') {
      $state = 'usage'
      continue
    }

    if ($line -match '^Options:') {
      $state = 'options'
      
      continue
    }

    if ($state -eq 'usage') {
      # replace '   |  ' with '|'
      $outerSegments = ($line -replace '\s*\|\s*', '|' -split ' ') | Select-Object -Skip 1
      # ex. "adduser", "install"
      $base_seg = $outerSegments | Select-Object -First 1
      $curr_segment = $npm
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
            $segments = $right.Split('|') | ForEach-Object {$left + $_}
          } else {
            $inner = $true
            $segments = $outerSegment.Split('|')
          }
        }
  
        foreach($segment in $segments) {
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

    if ($state -eq 'options') {
      if ($null -eq $base_seg) {
        Write-Error "uh oh 2..."
        continue
      }

      if ($null -eq $npm[$base_seg]) {
        Write-Error "uh oh 3..."
        continue
      }

      # Write-Host $base_seg

      # parse parts in a state machine, since some have args
      $parts = $line -split ' ' 
      $curr_sflag = $null
      $curr_flag = $null
      foreach ($part in $parts) {
        $part = $part.Trim('[', ']', ' ')
        # Write-Host $part, $base_seg, $base_sflags, $base_flags
        if ($part.StartsWith('-') -or $part.StartsWith('--')) {
          # consistently is -f|--flag
          $subflags = $part.split('|')
          foreach ($subflag in $subflags) {
            if ($subflag.StartsWith('--')) {
              if ($null -eq $npm[$base_seg]['$flags']) {
                $npm[$base_seg]['$flags'] = [ordered]@{}
              }
              $curr_flag = $subflag
              $npm[$base_seg]['$flags'][$curr_flag] = [ordered]@{}
              continue
            }
            if ($subflag.StartsWith('-')) {
              if ($null -eq $npm[$base_seg]['$sflags']) {
                $npm[$base_seg]['$sflags'] = [ordered]@{}
              }
              $curr_sflag = $subflag
              $npm[$base_seg]['$sflags'][$curr_sflag] = [ordered]@{}
              continue
            }
            Write-Error "entered fail flag parse state"
          }
          continue
        }
        if ($part.StartsWith('<')) {

          
          $sflags = try { $npm[$base_seg]['$sflags'][$curr_sflag] } catch [System.Management.Automation.RuntimeException] { $null }
          $flags = try { $npm[$base_seg]['$flags'][$curr_flag] } catch [System.Management.Automation.RuntimeException] { $null }

          # Write-Host $base_seg

          # only include flag args that have a defined enum, as indicated by <enum1|enum2>
          # otherwise if it just has <value1> that is ambigious and cannot be parsed
          $result = if ($part.Contains('|')) { $part.Trim('<', '>').Split('|') } else { $null } 

          if ($null -ne $flags) {
            $flags[$part] = $result
          }
          
          if ($null -ne $sflags) {
            $flags[$part] = $result
          }
        }
      }
    }

    if ($line -match '^aliases:') {
      $aliases = $line -replace '^aliases:\s+', '' -split "," | ForEach-Object {$_.Trim()}
      foreach ($alias in $aliases) {
        $whitelist = @('run')
        if ($whitelist -notcontains $alias) {
          # dont recommend unless whitelisted
          continue
        }

        # Write-Host $alias, $base_seg
        $npm[$alias] = $npm[$base_seg]
      }
    }
  }

  $toReturn = @{
    export_version         = $script:export_version.ToString();
    npm_version            = $script:npm_version;
    tree                   = $npm;
  }

  $toReturn | Export-Clixml -Path $script:path

  if ($PassThru) {
    $toReturn
  }
}

function Get-CompletionsNpm {
  param(
    [Parameter()]
    [string]$string,
  
    # removes last segment if it is partial word or flag
    # then gives all possibles
    [Parameter()]
    [switch]$allPossible
  )

  $string = ($string -replace '^npm\s+', '').Trim() -replace '\s{1,}', ' '
  $parts = $string -split ' '

  <#
  $last = $parts | Select-Object -Last 1

  if ([String]::IsNullOrEmpty($last)) {
    $last = $parts | Select-Object -Last 1
  }
  #>

  $clixml = $null

  if (-not (Test-Path $script:path -ErrorAction SilentlyContinue)) {
    $clixml = Export-CompletionsNpm -PassThru
  }

  if ($null -eq $clixml) {
    $clixml = Import-Clixml -Path $script:path
  }

  $npm = $clixml.tree

  $base = $parts | Select-Object -First 1
  $2ndlast = $parts[-2]
  $last = $parts | Select-Object -Last 1

  $options = @()
  $allOptions = @(
    try {$npm[$base]['$sflags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  ) + @(
    try {$npm[$base]['$flags'].Keys} catch [System.Management.Automation.RuntimeException] {$null}
  )

  if ($null -ne $2ndlast -and $2ndlast.StartsWith('-')) {
    if ($2ndlast.StartsWith('--')) {
      $options = $npm[$base]['$flags'][$2ndlast][0]
    } else {
      $options = $npm[$base]['$sflags'][$2ndlast][0]
    }
  }

  if ($options.Count -gt 0) {
    return $options
  }

  if ($last.StartsWith('-')) {
    if ($last.StartsWith('--')) {
      $options = $npm[$base]['$flags'].Keys
    } else {
      $options = $npm[$base]['$sflags'].Keys
    }
    # if we are complete, then don't use it
    if ($npm[$base]['$flags'].Keys -contains $last -or $npm[$base]['$sflags'].Keys -contains $last) {
      $options = @()
    } else {
      if (-not $allPossible) {
        return $options
      }
    }
  }

  $currently_at = $npm
  # values evaluated at runtime rather than beforehand
  $evaluated = @()

  # get as far as possible in autocomplete tree
  foreach ($part in $parts) {
    $next = try { $currently_at[$part] } catch [System.Management.Automation.RuntimeException] { $null }
    
    if ($null -eq $next) {
      # Read through all <.*> values, and parse them according to our helpers
      foreach ($possible in $currently_at.Keys) {
        if ($possible -match "<command>") {
          # npm run <command>
          $evaluated += "foobar yippee"
        }
      }
      # todo traversal of free-form like <>
      break
    }

    $currently_at = $next
  }

  # attempt to use -like
  $options = $currently_at.Keys 
    | Where-Object {$_ -like "$last*"}
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
    | Sort-Object -Property { $_.Length }

  # if we failed fallback to the tree
  if ($null -eq $options -or $options.Count -eq 0) {
    $options = $currently_at.Keys
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
    | Sort-Object -Property { $_.Length }
  }

  $options += $evaluated

  $allOptions += $currently_at.Keys
    | Where-Object {-not ($_.StartsWith('$') -or $_.StartsWith('<'))}
  
  # remove nullish values
  $allOptions = $allOptions | Where-Object { $null -ne $_ }

  # if we have $withFlags, always append flags regardless of whether we are searching for a flag
  if (-not $allPossible) {
    return $options
  }
  return $allOptions
}

# function Get-CompletionsNpm {
#   param(
#     [Parameter()]
#     [string]$string,
  
#     [Parameter()]
#     [switch]$allPossible
#   )
#   # stub
# }

function Register-CompletionsNpm {
  $GetCompletionsNpmRef = ${function:Get-CompletionsNpm}

  Register-ArgumentCompleter -CommandName 'npm' -ScriptBlock {
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
        $allSuggestions = & $GetCompletionsNpmRef @params
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
    return & $GetCompletionsNpmRef @params
  }.GetNewClosure()
}