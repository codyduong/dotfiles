[CmdletBinding(DefaultParametersetName='none')] 
param (
    [Parameter(Position=2, ParameterSetName="update")]$update
)

$script:account = "codyduong"
$script:repo    = "dotfiles"
$script:branch  = "main"

$script:dotfilesTempDir = Join-Path $env:TEMP "dotfiles"
if (![System.IO.Directory]::Exists($dotfilesTempDir)) {[System.IO.Directory]::CreateDirectory($dotfilesTempDir)}
$script:sourceFile = Join-Path $dotfilesTempDir "dotfiles.zip"
$script:dotfilesInstallDir = Join-Path $dotfilesTempDir "$repo-$branch"


function script:Get-File {
  param (
    [string]$url,
    [string]$file
  )
  Write-Host "Downloading $url to $file"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $url -OutFile $file
}

function Read-File {
    param (
        [string]$File,
        [string]$Destination = (Get-Location).Path
    )

    $filePath = Resolve-Path $File
    $destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

    If (($PSVersionTable.PSVersion.Major -ge 3) -and
        (
            [version](Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -ge [version]"4.5" -or
            [version](Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -ge [version]"4.5"
        )) {
        try {
            [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$filePath", "$destinationPath")
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    } else {
        try {
            $shell = New-Object -ComObject Shell.Application
            $shell.Namespace($destinationPath).copyhere(($shell.NameSpace($filePath)).items())
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    }
}

Get-File "https://github.com/$account/$repo/archive/$branch.zip" $sourceFile
if ([System.IO.Directory]::Exists($dotfilesInstallDir)) {[System.IO.Directory]::Delete($dotfilesInstallDir, $true)}
Read-File $sourceFile $dotfilesTempDir

# $null = Start-ThreadJob -Name "Bootstrap profile install" -StreamingHost $Host -ArgumentList $dotfilesInstallDir, $sourceFile, $update -ScriptBlock {
#     param($dotfilesInstallDir, $sourceFile, $update)
#     Push-Location $dotfilesInstallDir
#     & .\windows\scripts\bootstrap.ps1 $true $sourceFile $update
# }

Push-Location $dotfilesInstallDir
if ($update) {
    & .\windows\scripts\bootstrap.ps1 -update $true
    Pop-Location
} else {
    & .\windows\scripts\bootstrap.ps1 $true $sourceFile
    Pop-Location
    Invoke-Command { & "pwsh.exe" -NoLogo } -NoNewScope
}