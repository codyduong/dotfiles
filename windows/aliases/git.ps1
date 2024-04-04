# Contains my other git shorthands that are not in https://github.com/codyduong/powershell-git-aliases-plus/tree/master
# or not part of the oh-my-zsh aliases
function gcme {
  # this is just an alternate form of gcmsg, but easier imho
  git commit --message $args
}

# not really sure why this isn't loading from https://github.com/codyduong/powershell-git-aliases-plus
function gcan! {
	git commit -v -a --no-edit --amend $args
}