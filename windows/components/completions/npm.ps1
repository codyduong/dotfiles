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


function Register-CompletionsNpm {
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

  $segmentsPrev = @('npm', 'access', 'list', 'packages') # 1 1 1 1
  $segmentsInput = 'access list packages'
  $segmentsNow = @('npm', 'access', 'list', 'collaborators') # 2 2 2 1
  $segmentsNow = @('npm', 'access', 'get', 'status') # 3 3 1 1
  $segmentsNow = @('npm', 'access', 'set', 'status=public|private') # 4 4 1 1
  $segmentsNow = @('npm', 'access', 'set', 'mfa=none|publish|automation') # 5 5 2 1

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
      continue
    }

    if ($line -match '^All commands:') {
      Write-Host "foo"
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
      $segments = $line -split ' ' | Select-Object -Skip 1
      $curr_segment = $npm
      foreach ($segment in $segments) {
        $segment = $segment.Trim('[', ']', ' ')
        if ($null -eq $curr_segment ) {
          Write-Error 'uh oh...'
        }

        $isParameter = $false
        # handle parameters
        if ($segment -match '^<' -or $segment -match '>$') {
          $segment = "<$segment>" # put them back
          $isParameter = $true
          continue
        }

        # handle subcommands
        $this_segment = $(if ($null -ne $curr_segment[$segment]) { $curr_segment[$segment] } else { @() }) | Select-Object -Skip 1 -First 1
        if ($null -eq $this_segment) {
          # create a new node
          $curr_segment[$segment] = @($isParameter ? $null : $segment, [ordered]@{})
          # traverse deeper
          $curr_segment = $curr_segment[$segment][1]
        }
        else {
          # traverse deeper
          $curr_segment = $this_segment
        }
      }
    }

    if ($state -eq 'options') {
      
    }
  }

  $npm | Write-Pretty
}