if ($null -eq (Get-Command thefuck -ErrorAction SilentlyContinue)) {
  $env:PYTHONIOENCODING = 'utf-8'
  Invoke-Expression "$(thefuck --alias)"
}