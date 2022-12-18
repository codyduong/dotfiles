$script:dotfiles = [System.IO.Path]::Combine("$HOME",'dotfiles')

if (Test-Path $dotfiles) {
  Set-Location $dotfiles;
  git fetch & git pull;
  . .\windows\scripts\bootstrap.ps1;
} else {
  git clone https://github.com/codyduong/dotfiles.git $dotfiles
  Set-Location $dotfiles
  . .\windows\scripts\bootstrap.ps1
}