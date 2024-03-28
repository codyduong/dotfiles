# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Move komorebi directory
Set-Environment "KOMOREBI_CONFIG_HOME" (Join-Path -Path $Env:USERPROFILE -ChildPath '.config\komorebi\')

# pyenv-windows
Set-Environment "PYENV" (Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')
Set-Environment "PYENV_ROOT" (Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')
Set-Environment "PYENV_HOME" (Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')

# python scripts, ie. poetry
# Prepend-EnvPath $(Join-Path -Path $env:APPDATA -ChildPath 'Python\Scripts')

# alias-tips
Set-Environment "ALIASTIPS_FUNCTION_INTROSPECTION" $true

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'

$script:msys2Path = "C:\msys64\usr\bin"
$script:mingwPath = "C:\msys64\ucrt64\bin"
# PATH VARS
Update-EnvPathIfNot (Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\bin')
Update-EnvPathIfNot (Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\shims')
Update-EnvPathIfNot (Join-Path -Path $env:APPDATA -ChildPath 'Python\Scripts')
Update-EnvPathIfNot $msys2Path
Update-EnvPathIfNot $mingwPath
Update-EnvPathIfNot (Join-Path $env:LOCALAPPDATA "Programs\ILSpy")
Update-EnvPathIfNot (Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles)) "PowerShell\7")
Update-EnvPathIfNot (Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\bin")
Update-EnvPathIfNot (Join-Path $env:ProgramFiles "\Neovim\bin")
Update-EnvPathIfNot "C:\Qt\6.6.1\msvc2019_64\bin"
# https://stackoverflow.com/a/57403956/17954209
Update-EnvPathIfNot "C:\Qt\6.6.1\msvc2019_64\include"
Update-EnvPathIfNot "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
