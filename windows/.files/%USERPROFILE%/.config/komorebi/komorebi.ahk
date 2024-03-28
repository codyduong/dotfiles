#Requires AutoHotkey v2.0
#SingleInstance Force
#Include %A_ScriptDir%/komorebi.lib.ahk
; SendMode, Input
; SetBatchLines, -1

; Load library & configuration
; #Include komorebic.lib.ahk
; #Include komorebi.generated.ahk

; Send the ALT key whenever changing focus to force focus changes
AltFocusHack("enable")
; Default to cloaking windows when switching workspaces
WindowHidingBehaviour("cloak")
; Set cross-monitor move behaviour to insert instead of swap
CrossMonitorMoveBehaviour("Insert")
; Enable hot reloading of changes to this file
WatchConfiguration("enable")

; Create named workspaces I-V on monitor 0
; EnsureNamedWorkspaces(0, "I II III IV V")
; You can do the same thing for secondary monitors too
; EnsureNamedWorkspaces(1, "A B C D E F")

; Assign layouts to workspaces, possible values: bsp, columns, rows, vertical-stack, horizontal-stack, ultrawide-vertical-stack
; NamedWorkspaceLayout("I", "bsp")

; Set the gaps around the edge of the screen for a workspace
; NamedWorkspacePadding("I", 20)
; Set the gaps between the containers for a workspace
; NamedWorkspaceContainerPadding("I", 20)

; You can assign specific apps to named workspaces
; NamedWorkspaceRule("exe", "Firefox.exe", "III")

; Configure the invisible border dimensions
InvisibleBorders(7, 0, 14, 7)

; Uncomment the next lines if you want a visual border around the active window
; ActiveWindowBorderColour(66, 165, 245, "single")
; ActiveWindowBorderColour(256, 165, 66, "stack")
; ActiveWindowBorderColour(255, 51, 153, "monocle")

CompleteConfiguration()

; https://www.autohotkey.com/docs/v2/KeyList.html

; Focus windows
#h::Focus("left")
#j::Focus("down")
#k::Focus("up")
#l::Focus("right")
#+[::CycleFocus("previous")
#+]::CycleFocus("next")

; Move windows
#+h::Move("left")
#+j::Move("down")
#+k::Move("up")
#+l::Move("right")
#+Enter::Promote()

; Stack windows
#Left::Stack("left")
#Right::Stack("right")
#Up::Stack("up")
#Down::Stack("down")
#;::Unstack()
#[::CycleStack("previous")
#]::CycleStack("next")

; Resize
#=::ResizeAxis("horizontal", "increase")
#-::ResizeAxis("horizontal", "decrease")
#+=::ResizeAxis("vertical", "increase")
#+-::ResizeAxis("vertical", "decrease")

; Manipulate windows
#Space::ToggleFloat()
#+f::ToggleMonocle()

; Window manager options
#+r::Retile()
#+c::ReloadConfiguration()
#p::TogglePause()

; Layouts
; borizontal 😂
#b::FlipLayout("horizontal")
#v::FlipLayout("vertical")

; Workspaces
#1::FocusWorkspace(0)
#2::FocusWorkspace(1)
#3::FocusWorkspace(2)
#4::FocusWorkspace(3)
#5::FocusWorkspace(4)
#6::FocusWorkspace(5)
#7::FocusWorkspace(6)
#8::FocusWorkspace(7)
#9::FocusWorkspace(8)
#0::FocusWorkspace(9)

; Move windows across workspaces
#+1::MoveToWorkspace(0)
#+2::MoveToWorkspace(1)
#+3::MoveToWorkspace(2)
#+4::MoveToWorkspace(3)
#+5::MoveToWorkspace(4)
#+6::MoveToWorkspace(5)
#+7::MoveToWorkspace(6)
#+8::MoveToWorkspace(7)
#+9::MoveToWorkspace(8)
#+0::MoveToWorkspace(9)