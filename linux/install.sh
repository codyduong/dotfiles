# For installing without git
_git() {
  which git >/dev/null
    && echo "\033[1;33mgit found, skipping...\033[0m" 
    || (echo "\033[1;33minstalling git...\033[0m"; sudo apt install git -y)
  which git >/dev/null 
    && git clone https://github.com/codyduong/dotfiles ~/dotfiles 
    && ~/dotfiles/linux/bootstrap.sh
}
