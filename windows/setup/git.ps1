if (git clone https://github.com/codyduong/dotfiles.git "$([Environment]::GetFolderPath("MyDocuments"))/dotfiles") {
  Set-Location "$([Environment]::GetFolderPath("MyDocuments"))/dotfiles"
  . .\windows\scripts\bootstrap.ps1
} else {
  Set-Location "$([Environment]::GetFolderPath("MyDocuments"))/dotfiles";
  git fetch & git pull;
  . .\windows\scripts\bootstrap.ps1;
}