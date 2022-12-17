# version 0.0.0

# https://github.com/gluons/powershell-git-aliases/issues/27#issuecomment-1041301323
# Be aware that posh-git should be imported after git-aliases or any self-defined git alias/function, which is mentioned in this issue and solved in PR.
Push-Location (Split-Path -parent $profile)
# base-all ~3500ms
"components", #~1500ms
"functions",
"aliases", #~200ms
"exports"
| Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location
