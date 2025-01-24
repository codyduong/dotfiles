#Requires AutoHotkey v2.0
#SingleInstance Force
#Include %A_ScriptDir%/komorebi.lib.ahk

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
#^;::Unstack()
#[::CycleStack("previous")
#]::CycleStack("next")
#^h::Stack("left")
#^j::Stack("down")
#^k::Stack("up")
#^l::Stack("right")
#Tab::CycleStack("next")
#+Tab::CycleStack("prev")

; Resize
#=::ResizeAxis("horizontal", "increase")
#-::ResizeAxis("horizontal", "decrease")
#+=::ResizeAxis("vertical", "increase")
#+-::ResizeAxis("vertical", "decrease")

; Manipulate windows
#+Space::ToggleFloat()
#+x::ToggleMaximize()
#+f::ToggleMonocle()
#+z::ToggleZen()

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
