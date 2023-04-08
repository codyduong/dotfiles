enum PackageIs {
    notinstalled
    installed
    outdated
    unknown
}

$script:InstallationIndicatorColorInstalling    = "DarkCyan"
$script:InstallationIndicatorColorUpdating      = "DarkGreen"
$script:InstallationIndicatorColorFound         = "DarkGray"

function script:Find-WingetAll {
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

function script:Find-Winget {
    [CmdletBinding(DefaultParameterSetName='NameParameterSet')]
    param(
        [Parameter(ParameterSetName='NameParameterSet', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name}
    )

    $global:winget_table = $winget_table ?? @{}
    if ($winget_table.count -le 0) {
        Find-WingetAll
    }

    $version = [version]"0.0.0", [version]"0.0.0"
    [boolean]$installed = $false
    if ($winget_table[$Name]) {
        $installed = $true
        $version = $winget_table[$Name]
    }
    else {
        $output_lines = $(winget list -e --id $Name) | 
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
        if ($application_str -match $Name) {
            $installed = $true
        }

        $version = try {
            ($application_str | select-string -allmatches $regex).
            Matches[0] -split " "
        }
        catch [System.Management.Automation.RuntimeException] {
            $false
        }
    }
    if ($version -is [String]) {
        $version = $version, $null
    }

    if (-not $installed) {
        return [PackageIs]::notinstalled, $null
    }
    elseif ($version[0] -match "unknown") {
        return [PackageIs]::unknown, $version
    }
    elseif ($table_header -match "Available" -and ([version]($version[1] ?? "0.0.0") -gt [version]($version[0] ?? "0.0.0"))) {
        return [PackageIs]::outdated, $version
    }
    else {
        return [PackageIs]::installed, $version
    }
}

function Install-Winget {
    [CmdletBinding(DefaultParameterSetName='NameParameterSet')]
    param(
        [Parameter(ParameterSetName='NameParameterSet', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name}
    )

    $installed = Find-Winget $Name
    $i = $installed[0]
    $a = $installed[1]
    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($Name)..." -ForegroundColor $InstallationIndicatorColorInstalling
        winget install -e --id $Name
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($Name) from $($a[0]) to $($a[1])..." -ForegroundColor $InstallationIndicatorColorUpdating
        winget install -e --id $Name
    }
    else {
        Write-Host "$($Name) $($a[0]) found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
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

function script:Find-PowerShellModule {
    [CmdletBinding(DefaultParameterSetName='NameParameterSet')]
    param (
        [Parameter(ParameterSetName='NameParameterSet', Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [switch]
        ${AllowPrerelease}
    )

    $str_data = [string]$(Get-InstalledModule -Name $Name -AllowPrerelease:$AllowPrerelease -ErrorAction SilentlyContinue)
    if ($null -eq $str_data -or "" -eq ($str_data -replace "\s", "")) {
        return [PackageIs]::notinstalled
    }
    $current_hashtable = ConvertFrom-StringData -StringData ($str_data | PrepModuleToStr)
    $available_hashtable = ConvertFrom-StringData -StringData ($(Find-Module -Name $Name -AllowPrerelease:$AllowPrerelease) | PrepModuleToStr)

    $version = $current_hashtable['version'], $available_hashtable['version']
    try {
        # try converting with semver
        $version = [semver]$($current_hashtable['version']), [semver]$($available_hashtable['version'])
    }
    catch [System.Management.Automation.PSInvalidCastException] {
        try {
            # try converting with using regular ver
            $version = [version]$($current_hashtable['version']), [version]$($available_hashtable['version'])
        }
        catch [System.Management.Automation.PSInvalidCastException] {}
    }

    if ($version[1] -gt $version[0]) {
        return [PackageIs]::outdated, $version
    }
    else {
        return [PackageIs]::installed, $version
    }
}

function Install-PowerShell {
    [CmdletBinding(DefaultParameterSetName='NameParameterSet', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='https://go.microsoft.com/fwlink/?LinkID=398573')]
    param(
        [Parameter(ParameterSetName='NameParameterSet', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},
    
        [Parameter(ParameterSetName='NameParameterSet', ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${MinimumVersion},
    
        [Parameter(ParameterSetName='NameParameterSet', ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${MaximumVersion},
    
        [Parameter(ParameterSetName='NameParameterSet', ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${RequiredVersion},
    
        [Parameter(ParameterSetName='NameParameterSet')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Repository},
    
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},
    
        [ValidateSet('CurrentUser','AllUsers')]
        [string]
        ${Scope},
    
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Proxy},
    
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},
    
        [switch]
        ${AllowClobber},
    
        [switch]
        ${SkipPublisherCheck},
    
        [switch]
        ${Force},
    
        [Parameter(ParameterSetName='NameParameterSet')]
        [switch]
        ${AllowPrerelease},
    
        [switch]
        ${AcceptLicense},
    
        [switch]
        ${PassThru}
    )

    $PSBoundParameters.Remove("Name") | Out-Null

    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    $installed = Find-PowerShellModule $Name -AllowPrerelease:$AllowPrerelease
    $i = $installed[0]
    $a = $installed[1]

    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($Name)..." -ForegroundColor $InstallationIndicatorColorInstalling
        Install-Module @($Name) @PSBoundParameters
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($Name) from $($a[0]) to $($a[1])..." -ForegroundColor $InstallationIndicatorColorUpdating
        Install-Module @($Name) @PSBoundParameters
    }
    else {
        Write-Host "$($Name) $($a[0]) found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
    }
}

function Install-WinGetPackage {
    [CmdletBinding()]
    param()

    $winget = Get-Command winget -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "Name" -ErrorAction SilentlyContinue
    if ($winget) {
        Update-WinGetPackage
    } else {
        Update-WinGetPackage [version]0.0.0
    }
}

function Update-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
        [version]
        ${Version}
    )

    # check local version
    $localVersion = $Version ?? [version]$("$(winget -v)".TrimStart("v"))

    # get remote version
    $remote = Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest
    $latestVersion = [version]$($remote.tag_name.TrimStart("v"))

    Write-Verbose "Local winget version: v$localVersion"
    Write-Verbose "Latest winget version: v$latestVersion"

    if ($latestVersion -eq $localVersion) {
        Write-Host "winget $localVersion found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
        return $null
    }

    $asset = $remote.assets | Where-Object {$_.name -match "Microsoft\.DesktopAppInstaller_.*\.msixbundle$"}
    $url = $asset.browser_download_url
    $file = Join-Path $env:TEMP "WinGet" $asset.name
    Invoke-WebRequest -Uri $url -OutFile $file

    if ($latestVersion -eq 0.0.0) {
        Write-Host "Installing $($Name)..." -ForegroundColor $InstallationIndicatorColorInstalling
    }
    elseif ($latestVersion -gt $localVersion) {
        Write-Host "Updating winget from $localVersion to $latestVersion..." -ForegroundColor $InstallationIndicatorColorUpdating
    }
    Add-AppxPackage -Path $file

    return $null
}