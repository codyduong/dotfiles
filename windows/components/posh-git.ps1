Import-Module git-aliases-plus -DisableNameChecking
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  # 0.2 seconds? TODO @codyduong
  Import-Module Posh-Git -arg 0, 0, 1
}