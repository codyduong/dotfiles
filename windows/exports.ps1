# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Move komorebi directory
Set-Environment "KOMOREBI_CONFIG_HOME" "~/.config/komorebi"

# pyenv-windows
Set-Environment "PYENV" $(Join-Path $Env:USERPROFILE + '\.pyenv\pyenv-win\')
Set-Environment "PYENV_ROOT" $(Join-Path $Env:USERPROFILE + '\.pyenv\pyenv-win\')
Set-Environment "PYENV_HOME" $(Join-Path $Env:USERPROFILE + '\.pyenv\pyenv-win\')
Prepend-EnvPath $(Join-Path $Env:USERPROFILE + '\.pyenv\pyenv-win\bin')
Prepend-EnvPath $(Join-Path $Env:USERPROFILE + '\.pyenv\pyenv-win\shims')

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'
