# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Disable the Progress Bar
# $ProgressPreference='SilentlyContinue'

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression
Import-Module PSReadLine
Import-Module CompletionPredictor
Import-Module Terminal-Icons

# profiling
Import-Module PSProfiler