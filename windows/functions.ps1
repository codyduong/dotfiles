# Set a permanent Environment variable, and reload it into $env
function Set-Environment([String] $variable, [String] $value) {
    Set-ItemProperty "HKCU:\Environment" $variable $value
    # Manually setting Registry entry. SetEnvironmentVariable is too slow because of blocking HWND_BROADCAST
    #[System.Environment]::SetEnvironmentVariable("$variable", "$value","User")
    Invoke-Expression "`$env:${variable} = `"$value`""
}

# Add a folder to $env:Path
function Update-EnvPathIfNot {
    [CmdletBinding()]
    [String]$path

    if (-not (Test-Path $path)) {
        Write-Verbose "$path not found"
        return
    }
  
    $currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)
  
    if ($currentPath -notlike "*$path*") {
        $env:PATH = $currentPath + ";$path"
        Write-Verbose "$path added to the PATH"
    }
    else {
        Write-Verbose "$path is already in the PATH"
    }
}
