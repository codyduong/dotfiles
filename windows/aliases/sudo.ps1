function sudo() {
  Start-Process powershell.exe -verb runAs -ArgumentList '-WindowStyle', 'Hidden', '-Command', "cd $(Get-Location); $args"
}