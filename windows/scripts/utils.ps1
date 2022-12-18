enum PackageIs {
    notinstalled
    installed
    outdated
    unknown
}

$script:InstallationIndicatorColorInstalling    = "DarkCyan"
$script:InstallationIndicatorColorUpdating      = "DarkGreen"
$script:InstallationIndicatorColorFound         = "DarkGray"

function script:WingetListAll {
    $currentEncoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
            
        [array]$output_lines = $(winget list -s winget) | Where-Object { $_ -match "^\S+.*$" }
        $table_header = $output_lines[0]
        $valid_lines = $output_lines[2..($output_lines.Count - 1)]

        $global:winget_table = @{}
        $id_index = $table_header.IndexOf("Id")
        $version_index = $table_header.IndexOf("Version")
        ForEach ($line in $valid_lines) {
            $name = $line.substring($id_index, $version_index - $id_index - 1).Trim()
            $line = $line.substring($version_index).Trim()
            $line = $line -replace "\s(?=\s{1,})", ""
            # Write-Output $name $line
            $version = $line -split " "
            if ($version -is [String]) {
                $version = $version, $null
            }
            $winget_table[$name] = $version
        }
    }
    finally {
        [Console]::OutputEncoding = $currentEncoding
    }
}

function script:WingetIsPackageInstalled {
    param (
        [parameter(mandatory)][string]$packageStr
    )

    $global:winget_table = $winget_table ?? @{}
    if ($winget_table.count -le 0) {
        WingetListAll
    }

    $version = [version]"0.0.0", [version]"0.0.0"
    [boolean]$installed = $false
    if ($winget_table[$packageStr]) {
        $installed = $true
        $version = $winget_table[$packageStr]
    }
    else {
        $output_lines = $(winget list -e --id $packageStr) | 
        Where-Object { $_ -match "^\S+.*$" }
        $table_header = $output_lines[0]
        $application_str = $output_lines[2]
        $application_str = ($application_str -replace "\s(?=\s{1,})", "")
        $regex = if ($table_header -match "Available") {
            "((unknown )|([\w\.]* ))[\w\.]*(?= winget$)"
        }
        else {
            "((unknown )|([\w\.]*))(?= winget$)"
        }
        if ($application_str -match $packageStr) {
            $installed = $true
        }

        $version = try {
            ($application_str | select-string -allmatches $regex).
            Matches[0] -split " "
        }
        catch [InvalidOperationException] {
            $false
        }
    }
    if ($version -is [String]) {
        $version = $version, $null
    }

    if (-not $installed) {
        return [PackageIs]::notinstalled, $null
    }
    elseif ($version[0] -eq "unknown") {
        return [PackageIs]::unknown, $version
    }
    elseif ($table_header -match "Available" -and ([version]($version[1] ?? "0.0.0") -gt [version]($version[0] ?? "0.0.0"))) {
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
        Write-Host "Installing $($packageStr)..." -ForegroundColor $InstallationIndicatorColorInstalling
        winget install -e --id $packageStr
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($packageStr) from $($a[0]) to $($a[1])..." -ForegroundColor $InstallationIndicatorColorUpdating
        winget install -e --id $packageStr
    }
    else {
        Write-Host "$($packageStr) $($a[0]) found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
    }
}

function InstallerPromptUpdateOutdated() {
    $updateOutdated = PromptBooleanQuestion("Would you like to update existing dependencies") $true
    $Env:UPDATE_OUTDATED_DEPS = $updateOutdated
}

. $PSScriptRoot\..\components\utils.ps1

filter quoteStringWithSpecialChars {
    if ($_ -and ($_ -match '\s+|#|@|\$|;|,|''|\{|\}|\(|\)')) {
        $str = $_ -replace "'", "''"
        "'$str'"
    }
    else {
        $_
    }
}

function script:PrepModuleToStr {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$moduleStr
    )

    return $moduleStr -replace '^@{|}$', '' -replace '\\', '\\' -replace "`n", "\n" -replace '; ', "`n"
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
    if ($null -eq $packageStr -or $packageStr -match "^-") {
        $args -join " " -match "((?<=-[nN]ame\s)\S*)" | Out-Null
        $packageStr = $Matches[0]
    }
    $installed = PowershellModuleIsInstalled($packageStr)
    $i = $installed[0]
    $a = $installed[1]
    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($packageStr)..." -ForegroundColor $InstallationIndicatorColorInstalling
        Install-Module $packageStr @args
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($packageStr) from $($a[0]) to $($a[1])..." -ForegroundColor $InstallationIndicatorColorUpdating
        Install-Module $packageStr @args
    }
    else {
        Write-Host "$($packageStr) $($a[0]) found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
    }
}