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