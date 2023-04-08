# Directory Listing: Use `ls.exe` if available
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
  Remove-Item alias:ls -ErrorAction SilentlyContinue
  # Set `ls` to call `ls.exe` and always use --color
  ${function:ls} = { ls.exe --color @args }
  # List all files in long format
  ${function:l} = { Get-ChildItem -lF @args }
  # List all files in long format, including hidden files
  ${function:la} = { Get-ChildItem -laF @args }
  # List only directories
  ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}
else {
  # List all files, including hidden files
  ${function:la} = { Get-ChildItem -Force @args }
  # List only directories
  ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}
