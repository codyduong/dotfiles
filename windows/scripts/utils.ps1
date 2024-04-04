enum PackageIs {
    notinstalled
    installed
    outdated
    unknown
}

$InstallationIndicatorColorInstalling = "DarkCyan"
$InstallationIndicatorColorUpdating = "DarkGreen"
$InstallationIndicatorColorFound = "DarkGray"

function script:Convert-Version {
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("version")]
        [object]
        $versions
    )

    process {
        # If a single string is provided, treat it as an array with a single element
        if ($versions -is [string]) {
            $versions = @($versions)
        }

        $convertedVersions = $versions | ForEach-Object {
            # If it is unknown use version 0.0.0
            if ($_ -eq "Unknown") {
                return [version]"0.0.0"
            }

            $v = $null
            # OK this is dumb but just convert to a double LOL
            if ($null -ne $_) {
                if (-not [version]::TryParse($_, [ref]$v)) {
                    if (-not [semver]::TryParse($_, [ref]$v)) {
                        $v = [double]($_ -replace "\D*", '')
                    }
                }
            }
            return $v
        }

        return $convertedVersions
    }
}

function Find-WingetAll {
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
            $version = $line -split " "

            # if (($inputString -split '-').Count - 1 -eq 1) {
            #     # Valid semver revision strings will only have one dash and remove the text
            #     $line = $inputString -replace '-\D*', '.'
            # }

            # Some packages are formatted
            # MM/DD/YYYY, just remove the date and use the version
            # Others use '> sem.ver.patch' or '< sem.ver.patch'
            $version = $line -replace "\d{2}/\d{2}/\d\d{2,4}\w*", "" -replace "< |> ", "" -split " " | ForEach-Object { $_ -replace "[^\d\.]*", "" }

            if ($version -is [string]) {
                $version = $version, $null
            }

            # Replace first empty string (second indicates unknown update, which is never shown) with "Unknown"
            if ($version[0] -match '^\s*$') { $version = "Unknown", $version[1] }

            $winget_table[$name] = $version
        }
    }
    finally {
        [Console]::OutputEncoding = $currentEncoding
    }
}

function script:Start-FindModuleThreadJob {
    param($name, $version)
    return Start-ThreadJob -Name "$name aVers" -ThrottleLimit 20 -InitializationScript {
        Import-Module PowerShellGet
    } -ScriptBlock {
        param($name, $version)

        $availableModule = Find-Module -Name $name -ErrorAction SilentlyContinue
        $availableVersion = $availableModule.Version
        $toTable = @($version, $availableVersion)
        if ($availableVersion -gt $version) {
            $toTable = @($version, $availableVersion)
        }

        $availableModule = Find-Module -Name $name -AllowPrerelease -ErrorAction SilentlyContinue
        $availableVersion = $availableModule.Version
        $toTablePrerelease = @($version, $availableVersion)
        if ($availableVersion -gt $version) {
            $toTablePrerelease = @($version, $availableVersion)
        }

        return @{ "normal" = $toTable; "prerelease" = $toTablePrerelease }
    } -ArgumentList $name, $version
}

$global:jobsToClean = [System.Collections.ArrayList]@()

function Find-PowershellAll {
    ForEach ($module in Get-InstalledModule) {
        $name, $version = $module.Name, $module.Version
        $job = Start-FindModuleThreadJob $name $version
        $global:jobsToClean.Add($job)
    }
}

function Clear-PowershellAll {
    foreach ($job in $global:jobsToClean) {
        if ($job.State -eq 'Running') {
            Stop-Job $job
        }
        Remove-Job $job
    }
}

function script:Find-Winget {
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet')]
    param(
        [Parameter(ParameterSetName = 'NameParameterSet', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName = 'NameParameterSet')]
        [scriptblock]
        ${GetCurrent},

        [Parameter(ParameterSetName = 'NameParameterSet')]
        [scriptblock]
        ${GetAvailable}
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
        # If we only have one version, it means there was no version to update to
        $version = $version, $null
    }
    if ($GetCurrent) {
        $version = @($(Invoke-Command -ScriptBlock $GetCurrent), $version[1])
    }
    if ($GetAvailable) {
        $version = @($version[0], $(Invoke-Command -ScriptBlock $GetAvailable))
    }

    $newver = Convert-Version $version

    if (-not $installed) {
        return [PackageIs]::notinstalled, $null
    }
    elseif ($newver[0] -match "Unknown") {
        return [PackageIs]::unknown, $version
    }
    elseif ($newver[1] -gt $newver[0]) {
        return [PackageIs]::outdated, $version
    }
    else {
        return [PackageIs]::installed, $version
    }
}

function Install-Winget {
    <#
    .SYNOPSIS
    Custom install winget function, handling automatic updating

    .PARAMETER GetCurrent
    Specifies a custom ScriptBlock to determine the current verison. Useful if a package
    is installed, but the version reads as unknown.

    The expected ScriptBlock should have no parameters, and a return of Version or SemanticVersion
    #>
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet')]
    param(
        [Parameter(ParameterSetName = 'NameParameterSet', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName = 'NameParameterSet')]
        [scriptblock]
        ${GetCurrent},

        [Parameter(ParameterSetName = 'NameParameterSet')]
        [scriptblock]
        ${GetAvailable}
    )

    $installed = Find-Winget $Name -GetCurrent $GetCurrent -GetAvailable $GetAvailable
    $i = $installed[0]
    $a = $installed[1]
    $updateOutdated = $Env:UPDATE_OUTDATED_DEPS
    if ($i -eq [PackageIs]::notinstalled) {
        Write-Host "Installing $($Name)..." -ForegroundColor $InstallationIndicatorColorInstalling
        winget install -e --id $Name
    }
    elseif ($i -eq [PackageIs]::outdated -and $updateOutdated -eq $true) {
        Write-Host "Updating $($Name) from $($a[0]) to $($a[1])..." -ForegroundColor $InstallationIndicatorColorUpdating
        winget update -e --id $Name
    }
    else {
        Write-Host "$($Name) $($a[0]) found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
    }
}

function InstallerPromptUpdateOutdated() {
    $updateOutdated = PromptBooleanQuestion("Would you like to update existing dependencies") $false
    $Env:UPDATE_OUTDATED_DEPS = $updateOutdated
}

. $PSScriptRoot\..\components\utils.ps1

function script:Find-PowerShellModule {
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet')]
    param (
        [Parameter(ParameterSetName = 'NameParameterSet', Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [switch]
        ${AllowPrerelease}
    )

    $current_aVers = Get-Job | Where-Object Name -Match "$Name aVers"
    if ($current_aVers.count -le 0) {
        $job = Start-FindModuleThreadJob $name $version
        $global:jobsToClean.Add($job)
    }

    $job = Get-Job -Name "$Name aVers"
    $module = $null
    if ($job.State -eq 'Completed') {
        $module = Receive-Job -Job $job
    }
    else {
        $module = Receive-Job -Job $job -Wait
    }

    if ($null -eq $module -or $Name -eq "PowershellHumanizer") {
        $imodule = Get-InstalledModule -Name $Name -AllowPrerelease:$AllowPrerelease
        $module = $(Start-FindModuleThreadJob $Name $imodule.Version) | Receive-Job -Wait
    }

    if ($AllowPrerelease) {
        $prerelease = $module['prerelease']
        if ($null -eq $prerelease) {
            return [PackageIs]::notinstalled
        }
        if ($prerelease[1] -gt $prerelease[0]) {
            return [PackageIs]::outdated, @($prerelease)
        }
        return [PackageIs]::installed, @($prerelease)
    }

    $normal = $module['normal']
    if ($null -eq $normal) {
        return [PackageIs]::notinstalled
    }
    if ($normal[1] -gt $normal[0]) {
        return [PackageIs]::outdated, @($normal)
    }
    return [PackageIs]::installed, @($normal)
}

function Install-PowerShell {
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=398573')]
    param(
        [Parameter(ParameterSetName = 'NameParameterSet', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},
    
        [Parameter(ParameterSetName = 'NameParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [string]
        ${MinimumVersion},
    
        [Parameter(ParameterSetName = 'NameParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [string]
        ${MaximumVersion},
    
        [Parameter(ParameterSetName = 'NameParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [string]
        ${RequiredVersion},
    
        [Parameter(ParameterSetName = 'NameParameterSet')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Repository},
    
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},
    
        [ValidateSet('CurrentUser', 'AllUsers')]
        [string]
        ${Scope},
    
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Proxy},
    
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},
    
        [switch]
        ${AllowClobber},
    
        [switch]
        ${SkipPublisherCheck},
    
        [switch]
        ${Force},
    
        [Parameter(ParameterSetName = 'NameParameterSet')]
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

    # Write-Host $i $a

    if ($i -eq [PackageIs]::notinstalled -or $true) {
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

function Install-GitHubRelease {
    [CmdletBinding(DefaultParameterSetName = 'NameParameterSet')]
    param(
        [Parameter(ParameterSetName = 'NameParameterSet', Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Repository},

        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Match},

        [Parameter(ValueFromPipelineByPropertyName)]
        [semver]
        ${Version},

        [Parameter(ValueFromPipelineByPropertyName)]
        [semver]
        ${RemoteVersion},

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        ${WhatIf},

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        ${NoAction}
    )

    $Version = if ($null -eq $version) { $(Invoke-Expression "$Name --version").TrimStart("v") | Convert-Version } else { $Version }

    $PSBoundParameters.Remove("Version") | Out-Null

    $Installed = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "Name" -ErrorAction SilentlyContinue

    if ($Installed) {
        if ($updateOutdated -eq $true) {
            return Update-GitHubRelease $Version @PSBoundParameters
        }
        Write-Host "$Name $Version found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
        return $null
    }
    else {
        return Update-GitHubRelease $Version @PSBoundParameters
    }
}

function Update-GitHubRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [semver]
        ${Version},

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Repository},

        [Parameter(Mandatory, Position = 3, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Match},

        [Parameter(ValueFromPipelineByPropertyName)]
        [semver]
        ${RemoteVersion},

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        ${WhatIf},

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        ${NoAction}
    )

    # get remote version
    $Remote = Invoke-RestMethod https://api.github.com/repos/$Repository/releases/latest
    $LatestVersion = $RemoteVersion ?? [semver]$($Remote.tag_name.TrimStart("v"))

    Write-Verbose "Local $Name version: v$Version"
    Write-Verbose "Latest $Name version: v$LatestVersion"

    if ($LatestVersion -eq $Version -or $Version -ge $LatestVersion) {
        Write-Host "$Name $Version found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
        return $null
    }

    $Asset = $Remote.assets | Where-Object { $_.name -match $Match }
    $Url = $asset.browser_download_url
    $Temp = Join-Path $env:TEMP "Github"
    $File = Join-Path $Temp $Asset.name
    New-Item $Temp -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path -Path $File)) {
        Invoke-WebRequest -Uri $Url -OutFile $File
    }

    if ($Version -eq [semver]"0.0.0") {
        Write-Host "Installing $Name..." -ForegroundColor $InstallationIndicatorColorInstalling
    }
    elseif ($LatestVersion -gt $Version -and $updateOutdated -eq $true) {
        Write-Host "Updating $Name from $Version to $LatestVersion..." -ForegroundColor $InstallationIndicatorColorUpdating
    }
    else {
        Write-Host "$Name $Version found, skipping..." -ForegroundColor $InstallationIndicatorColorFound
    }

    # If we have a NoAction, return the path for the callee to handle
    if ($NoAction) {
        return $File
    }

    # Handle zipped files
    if ($File -match ".*\.zip") {
        $Destination = ($File -replace "\.zip$", "")
        Expand-Archive -LiteralPath $File -DestinationPath $Temp -Force
        $File = $Destination
        # Todo iterate over inside files to find msixbundle or exe. If the .exe is an installer specify with installer flag
        # otherwise add binary to path
    }
    # Handle .msixbundle with AppX
    elseif ($File -match ".*\.msixbundle$") {
        Add-AppxPackage -Path $File -WhatIf:$WhatIf
    }
    # Handle .exe
    elseif ($File -match ".*\.exe$") {
        Start-Process -FilePath $File -WhatIf:$WhatIf
    }
    elseif ($File -match ".*\.msi$") {
        Start-Process msiexec.exe -ArgumentList "/i $File" -Wait
    }
    else {
        Write-Warning "Unsupported file extension on file: $File"
    }

    return $null
}


function Invoke-ElevatedScript {
    param(
        [Parameter(Mandatory, Position = 0)]
        [scriptblock]
        ${script},

        [ValidateSet("Normal", "Minimized", "Maximized", "Hidden")]
        [string]
        ${WindowStyle} = "Hidden"
    )

    $PSBoundParameters.Remove("script") | Out-Null

    # Elevate if needed
    try {
        if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            $CommandLine = @(
                "-NoExit",
                # "-File `"" + $MyInvocation.MyCommand.Path + "`"",
                # https://stackoverflow.com/a/76043154
                "-Command `"Invoke-Command -ScriptBlock { $($script -replace '(?<!\\)(\\*)"', '$1$1\"') }`""
            )
            Start-Process @PSBoundParameters -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            return
        }

        Invoke-Command -ScriptBlock $script
    }
    catch [System.InvalidOperationException] {
        return
    }
}