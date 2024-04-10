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

. $PSScriptRoot\komorebi.generated.ps1
. $PSScriptRoot\komorebi.manual.ps1

# Send the ALT key whenever changing focus to force focus changes
komorebic alt-focus-hack enable
# Default to minimizing windows when switching workspaces
komorebic window-hiding-behaviour cloak
# Set cross-monitor move behaviour to insert instead of swap
komorebic cross-monitor-move-behaviour insert
# Enable hot reloading of changes to this file
komorebic watch-configuration enable

# create named workspaces I-V on monitor 0
# komorebic ensure-named-workspaces 0 I II III IV V
# you can do the same thing for secondary monitors too
# komorebic ensure-named-workspaces 1 A B C D E F

# assign layouts to workspaces, possible values: bsp, columns, rows, vertical-stack, horizontal-stack, ultrawide-vertical-stack
# komorebic named-workspace-layout I bsp

# set the gaps around the edge of the screen for a workspace
# komorebic named-workspace-padding I 20

# set the gaps between the containers for a workspace
# komorebic named-workspace-container-padding I 20

# you can assign specific apps to named workspaces
# komorebic named-workspace-rule exe "Firefox.exe" III

# Configure the invisible border dimensions
komorebic invisible-borders 7 0 14 7

# Uncomment the next lines if you want a visual border around the active window
komorebic active-window-border-colour 66 165 245 --window-kind single
komorebic active-window-border-colour 256 165 66 --window-kind stack
komorebic active-window-border-colour 255 51 153 --window-kind monocle
komorebic active-window-border enable

# Tile console/pwsh
komorebic manage-rule exe PowerShell.exe
komorebic manage-rule exe conhost.exe
komorebic manage-rule exe pwsh.exe

# Focus follows mouse
# komorebic toggle-focus-follows-mouse --implementation komorebi  

# Retile
komorebic retile

komorebic complete-configuration