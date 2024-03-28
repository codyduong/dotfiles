# https://stackoverflow.com/a/27975295/

# Elevate if needed
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  $commandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" -NoProfile" # + $MyInvocation.UnboundArguments
  Start-Process -WindowStyle Hidden -FilePath PowerShell.exe -Verb Runas -ArgumentList $commandLine
  Exit
}

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableLockWorkstation /f
rundll32.exe user32.dll, LockWorkStation

# Create a task to disable locking after unlocking
# @codyduong: There is a security policy here preventing this task from being runnable as an admin... w/e
#
# $taskName = "DisableLockWorkstationTask"
# if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
#   $command = "reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableLockWorkstation /t REG_DWORD /d 1 /f"
#   $action = New-ScheduledTaskAction -Execute "powershell" -Argument $command
#   $trigger = New-ScheduledTaskTrigger -AtLogon
#   Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -User "NT AUTHORITY\SYSTEM" -RunLevel Highest
# }

# If we disable it too fast, we won't be able to actually logout
Start-Sleep -Milliseconds 500
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableLockWorkstation /t REG_DWORD /d 1 /f
