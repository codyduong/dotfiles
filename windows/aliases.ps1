Get-ChildItem -Path "./aliases" |
Where-Object { $_.extension -eq ".ps1" } |
Where-Object { $_.Name[0] -ne "." } |
ForEach-Object -process { Invoke-Expression ". '$_'" }

# curl: Use `curl.exe` if available
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
    Remove-Item alias:curl -ErrorAction SilentlyContinue
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
Set-Alias grep findstr
Set-Alias _ sudo
Set-Alias procexp procexp64