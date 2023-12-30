# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Move komorebi directory
Set-Environment "KOMOREBI_CONFIG_HOME" $(Join-Path -Path $Env:USERPROFILE -ChildPath '.config\komorebi\')

# pyenv-windows
Set-Environment "PYENV" $(Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')
Set-Environment "PYENV_ROOT" $(Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')
Set-Environment "PYENV_HOME" $(Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\')

# python scripts, ie. poetry
# Prepend-EnvPath $(Join-Path -Path $env:APPDATA -ChildPath 'Python\Scripts')

# alias-tips
Set-Environment "ALIASTIPS_FUNCTION_INTROSPECTION" $true

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'

# PATH VARS
Update-EnvPathIfNot $(Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\bin')
Update-EnvPathIfNot $(Join-Path -Path $Env:USERPROFILE -ChildPath '.pyenv\pyenv-win\shims')
Update-EnvPathIfNot $(Join-Path -Path $env:APPDATA -ChildPath 'Python\Scripts')
Update-EnvPathIfNot $msys2Path
Update-EnvPathIfNot $mingwPath
Update-EnvPathIfNot $(Join-Path $env:LOCALAPPDATA "Programs\ILSpy")
