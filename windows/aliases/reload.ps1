function reload() {
  Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}