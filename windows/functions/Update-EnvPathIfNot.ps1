function Update-EnvPathIfNot {
  param(
      [Parameter(Mandatory = $true, Position = 0)][string]$path
  )

  if (-not (Test-Path $path)) {
      return
  }

  $currentPath = $env:PATH

  if ($currentPath -notlike "*$path*") {
      $env:PATH = $currentPath + ";$path"
      Write-Verbose "$path added to the PATH"
  }
  else {
      Write-Verbose "$path is already in the PATH"
  }
}