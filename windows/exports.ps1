# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Move komorebi directory
Set-Environment "KOMOREBI_CONFIG_HOME" "~/.config/komorebi"

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'
