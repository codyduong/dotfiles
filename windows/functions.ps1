# Set a permanent Environment variable, and reload it into $env
function Set-Environment([String] $variable, [String] $value) {
    Set-ItemProperty "HKCU:\Environment" $variable $value
    # Manually setting Registry entry. SetEnvironmentVariable is too slow because of blocking HWND_BROADCAST
    #[System.Environment]::SetEnvironmentVariable("$variable", "$value","User")
    Invoke-Expression "`$env:${variable} = `"$value`""
}

function CreateDirectory([String] $path) { New-Item $path -ItemType Directory -ErrorAction SilentlyContinue }
function CreateAndSet-Directory([String] $path) { New-Item $path -ItemType Directory -ErrorAction SilentlyContinue; Set-Location $path }

# Add a folder to $env:Path
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
