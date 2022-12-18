# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
# PoSh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

# Navigation Shortcuts
# ${function:dt} = { Set-Location ~\Desktop }
# ${function:docs} = { Set-Location ~\Documents }
# ${function:dl} = { Set-Location ~\Downloads }

# Correct PowerShell Aliases if tools are available (aliases win if set)
# WGet: Use `wget.exe` if available
# if (Get-Command wget.exe -ErrorAction SilentlyContinue | Test-Path) {
#   rm alias:wget -ErrorAction SilentlyContinue
# }

# Directory Listing: Use `ls.exe` if available
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
    rm alias:ls -ErrorAction SilentlyContinue
    # Set `ls` to call `ls.exe` and always use --color
    ${function:ls} = { ls.exe --color @args }
    # List all files in long format
    ${function:l} = { ls -lF @args }
    # List all files in long format, including hidden files
    ${function:la} = { ls -laF @args }
    # List only directories
    ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}
else {
    # List all files, including hidden files
    ${function:la} = { ls -Force @args }
    # List only directories
    ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}

# curl: Use `curl.exe` if available
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
    rm alias:curl -ErrorAction SilentlyContinue
    # Set `ls` to call `ls.exe` and always use --color
    ${function:curl} = { curl.exe @args }
    # Gzip-enabled `curl`
    ${function:gurl} = { curl --compressed @args }
}
else {
    # Gzip-enabled `curl`
    ${function:gurl} = { curl -TransferEncoding GZip }
}

# Create a new directory and enter it
Set-Alias mkdir CreateDirectory
Set-Alias mkdircd CreateAndSet-Directory
# Determine size of a file or total size of a directory
Set-Alias fs Get-DiskUsage
# Empty the Recycle Bin on all drives
Set-Alias emptytrash Empty-RecycleBin
# Cleanup old files all drives
Set-Alias cleandisks Clean-Disks
# http://xkcd.com/530/
Set-Alias mute Set-SoundMute
Set-Alias unmute Set-SoundUnmute
Set-Alias update System-Update

Set-Alias vim nvim
Set-Alias less 'C:\Program Files (x86)\Less\less.exe'
Set-Alias grep findstr
# which is a function already loaded in functions.ps1
# Set-Alias which which

# PS-Readline
$PSReadLineOptions = @{
    PredictionSource    = "HistoryAndPlugin"
    PredictionViewStyle = "ListView"
}
Set-PSReadLineOption @PSReadLineOptions

function reload() {
    Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}

# poetry
function poetry {
    & "$env:APPDATA\Python\Scripts\poetry.exe" $args
}