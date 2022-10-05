# Make vim the default editor
Set-Environment "EDITOR" "nvim --nofork"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'

# oh-my-posh
# https://ohmyposh.dev/docs/themes
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression

# autocomplete-like-fish
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# terminal icons
Import-Module Terminal-Icons