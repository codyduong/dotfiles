& $bashPath -c "chmod +x $PSScriptRoot/mingw.sh"
$bashOutput = & "$msys2Path\bash.exe" -c "$PSScriptRoot/mingw.sh" 2>&1
Write-Output $bashOutput