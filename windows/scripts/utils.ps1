enum PackageIs {
    notinstalled
    installed
    outdated
}

function script:WingetIsPackageInstalled {
    param (
        [parameter(mandatory)][string]$packageStr
    )

    $output_lines = $(winget list -e --id $packageStr) | 
    Where-Object { $_ -match "^\S+.*$" }
    $table_header = $output_lines[0]
    $application_str = $output_lines[2]
    $version = ($application_str -replace "[^\d\W]|\.(?=[^\d\W])", "").Trim() -split " "
    if ($application_str -notmatch $packageStr) {
        return [PackageIs]::notinstalled, $null
    }
    elseif ($table_header -match "Available" -and ($version[1] -gt $version[0])) {
        return [PackageIs]::outdated, $version
    }
    else {
        return [PackageIs]::installed, $version
    }
}

function WingetInstall {
    param (
        [parameter(mandatory)][string]$packageStr
    )

    $installed = WingetIsPackageInstalled($packageStr)
    $i = $installed[0]
    $a = $installed[1]
    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($packageStr)..." -ForegroundColor "Cyan"
        winget install -e --id $packageStr
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($packageStr) from $($a[0]) to $($a[1])..." -ForegroundColor "Cyan"
        winget install -e --id $packageStr
    }
    else {
        Write-Host "$($packageStr) $($a[0]) found, skipping..." -ForegroundColor "Cyan"
    }
}

function InstallerPromptUpdateOutdated() {
    $updateOutdated = PromptBooleanQuestion("Update existing deps")
    $Env:UPDATE_OUTDATED_DEPS = $updateOutdated
}

function PromptBooleanQuestion {
    param (
        [parameter(mandatory)][string]$promptStr
    )
    
    $answer = $null
    while ($null -eq $answer) {
        $prompt = Read-Host "$($promptStr) (y/n)?"
        try {
            $answer = $prompt -match "[yYnN]" ? $prompt -match "[yY]" : $null
        }
        catch {
            
        }
        if ($null -eq $answer) {
            Write-Host "Invalid input, received: " -ForegroundColor "Red" -NoNewline
            Write-Host "$($prompt)"
            Write-Host "`texpected one of: " -ForegroundColor "Red" -NoNewline
            Write-Host 'y', 'Y', 'n', 'N'
        }
    }
    return $answer
}

function script:PrepModuleToStr {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$moduleStr
    )

    return $moduleStr -replace '^@{|}$', '' -replace '\\', '\\' -replace '; ', "`n"
}

function script:PowershellModuleIsInstalled {
    param (
        [parameter(mandatory)][string]$packageStr
    )

    $str_data = [string]$(Get-InstalledModule -Name $packageStr -ErrorAction SilentlyContinue)
    if ($null -eq $str_data -or "" -eq ($str_data -replace "\s", "")) {
        return [PackageIs]::notinstalled
    }
    $current_hashtable = ConvertFrom-StringData -StringData ($str_data | PrepModuleToStr)
    $available_hashtable = ConvertFrom-StringData -StringData ($(Find-Module -Name $packageStr) | PrepModuleToStr)

    $version = $current_hashtable['version'], $available_hashtable['version']

    if ($version[1] -gt $version[0]) {
        return [PackageIs]::outdated, $version
    }
    else {
        return [PackageIs]::installed, $version
    }
}

function PowershellInstall($packageStr) {
    $installed = PowershellModuleIsInstalled($packageStr)
    $i = $installed[0]
    $a = $installed[1]
    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($packageStr)..." -ForegroundColor "Cyan"
        Install-Module $packageStr @args
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($packageStr) from $($a[0]) to $($a[1])..." -ForegroundColor "Cyan"
        Install-Module $packageStr @args
    }
    else {
        Write-Host "$($packageStr) $($a[0]) found, skipping..." -ForegroundColor "Cyan"
    }
}