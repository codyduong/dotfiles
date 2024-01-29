if ($null -ne (Get-Command thefuck -ErrorAction SilentlyContinue)) {
  $env:PYTHONIOENCODING = 'utf-8'
  Invoke-Expression "$(thefuck --alias)"
}