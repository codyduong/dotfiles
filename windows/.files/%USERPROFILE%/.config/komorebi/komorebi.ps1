if (!(Get-Process whkd -ErrorAction SilentlyContinue))
{
    # Start-Process whkd -WindowStyle hidden
    # use AHK2 instead
}

# Load ahk if possible
Import-Module $(Join-Path $(Split-Path -parent $profile) "aliases/ahk.ps1")

if (!(Get-Process ahk -ErrorAction SilentlyContinue)) {
    ahk $(Join-Path $PSScriptRoot 'komorebi.ahk')
}

# . $PSScriptRoot\komorebi.generated.ps1
. $PSScriptRoot\komorebi.manual.ps1

# Retile
komorebic retile

komorebic complete-configuration