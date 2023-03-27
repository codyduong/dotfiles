# derived from https://github.com/gluons/powershell-git-aliases
. $PSScriptRoot\gitAliasUtils.ps1

# Prevent conflict with built-in aliases
Remove-Alias gc -Force -ErrorAction SilentlyContinue
Remove-Alias gcb -Force -ErrorAction SilentlyContinue
Remove-Alias gcm -Force -ErrorAction SilentlyContinue
Remove-Alias gcs -Force -ErrorAction SilentlyContinue
Remove-Alias gl -Force -ErrorAction SilentlyContinue
Remove-Alias gm -Force -ErrorAction SilentlyContinue
Remove-Alias gp -Force -ErrorAction SilentlyContinue
Remove-Alias gpv -Force -ErrorAction SilentlyContinue

function g {
	aliasRun { git $args } $args
}
function ga {
	aliasRun { git add $args } $args
}
function gaa {
	aliasRun { git add --all $args } $args
}
function gapa {
	aliasRun { git add --patch $args } $args
}
function gau {
	aliasRun { git add --update $args } $args
}
function gav {
	aliasRun { git add --verbose $args } $args
}
function gb {
	aliasRun { git branch $args } $args
}
function gba {
	aliasRun { git branch -a $args } $args
}
function gbd {
	aliasRun { git branch -d $args } $args
}
function gbda {
	$MainBranch = Get-Git-MainBranch
	$MergedBranchs = $(git branch --merged | Select-String "^(\*|\s*($MainBranch|develop|dev)\s*$)" -NotMatch).Line
	$MergedBranchs | ForEach-Object {
		if ([string]::IsNullOrEmpty($_)) {
			return
		}
		git branch -d $_.Trim()
	}
}
function gbl {
	aliasRun { git blame -b -w $args } $args
}
function gbnm {
	aliasRun { git branch --no-merged $args } $args
}
function gbr {
	aliasRun { git branch --remote $args } $args
}
function gbs {
	aliasRun { git bisect $args } $args
}
function gbsb {
	aliasRun { git bisect bad $args } $args
}
function gbsg {
	aliasRun { git bisect good $args } $args
}
function gbsr {
	aliasRun { git bisect reset $args } $args
}
function gbss {
	aliasRun { git bisect start $args } $args
}
function gc {
	aliasRun { git commit -v $args } $args
}
function gc! {
	aliasRun { git commit -v --amend $args } $args
}
function gcn! {
	aliasRun { git commit -v --no-edit --amend $args } $args
}
function gca {
	aliasRun { git commit -v -a $args } $args
}
function gcam {
	aliasRun { git commit -a -m $args } $args
}
function gca! {
	aliasRun { git commit -v -a --amend $args } $args
}
function gcan! {
	aliasRun { git commit -v -a --no-edit --amend $args } $args
}
function gcans! {
	aliasRun { git commit -v -a -s --no-edit --amend $args } $args
}
function gcb {
	aliasRun { git checkout -b $args } $args
}
function gcf {
	aliasRun { git config --list $args } $args
}
function gcl {
	aliasRun { git clone --recursive $args } $args
}
function gclean {
	aliasRun { git clean -df $args } $args
}
function gcm {
	$MainBranch = Get-Git-MainBranch

	aliasRun { git checkout $MainBranch $args } $args
}
function gcd {
	aliasRun { git checkout develop $args } $args
}
function gcmsg {
	aliasRun { git commit -m $args } $args
}
function gco {
	aliasRun { git checkout $args } $args
}
function gcount {
	aliasRun { git shortlog -sn $args } $args
}
function gcp {
	aliasRun { git cherry-pick $args } $args
}
function gcpa {
	aliasRun { git cherry-pick --abort $args } $args
}
function gcpc {
	aliasRun { git cherry-pick --continue $args } $args
}
function gcs {
	aliasRun { git commit -S $args } $args
}
function gd {
	aliasRun { git diff $args } $args
}
function gdca {
	aliasRun { git diff --cached $args } $args
}
function gdt {
	aliasRun { git diff-tree --no-commit-id --name-only -r $args } $args
}
function gdw {
	aliasRun { git diff --word-diff $args } $args
}
function gf {
	aliasRun { git fetch $args } $args
}
function gfa {
	aliasRun { git fetch --all --prune $args } $args
}
function gfo {
	aliasRun { git fetch origin $args } $args
}
function gg {
	aliasRun { git gui citool $args } $args
}
function gga {
	aliasRun { git gui citool --amend $args } $args
}
function ggf {
	$CurrentBranch = Get-Git-CurrentBranch

	git push --force origin $CurrentBranch
}
function ggfl {
	$CurrentBranch = Get-Git-CurrentBranch

	git push --force-with-lease origin $CurrentBranch
}
function ghh {
	aliasRun { git help $args } $args
}
function ggsup {
	$CurrentBranch = Get-Git-CurrentBranch

	git branch --set-upstream-to=origin/$CurrentBranch
}
function gpsup {
	$CurrentBranch = Get-Git-CurrentBranch

	git push --set-upstream origin $CurrentBranch
}
function gignore {
	aliasRun { git update-index --assume-unchanged $args } $args
}
function gignored {
	git ls-files -v | Select-String "^[a-z]" -CaseSensitive
}
function gl {
	aliasRun { git pull $args } $args
}
function glg {
	aliasRun { git log --stat --color $args } $args
}
function glgg {
	aliasRun { git log --graph --color $args } $args
}
function glgga {
	aliasRun { git log --graph --decorate --all $args } $args
}
function glgm {
	aliasRun { git log --graph --max-count=10 $args } $args
}
function glgp {
	aliasRun { git log --stat --color -p $args } $args
}
function glo {
	aliasRun { git log --oneline --decorate --color $args } $args
}
function glog {
	aliasRun { git log --oneline --decorate --color --graph $args } $args
}
function gloga {
	aliasRun { git log --oneline --decorate --color --graph --all $args } $args
}
function glol {
	aliasRun { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $args } $args
}
function glola {
	aliasRun { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all $args } $args
}
function gm {
	aliasRun { git merge $args } $args
}
function gmom {
	$MainBranch = Get-Git-MainBranch

	aliasRun { git merge origin/$MainBranch $args } $args
}
function gmt {
	aliasRun { git mergetool --no-prompt $args } $args
}
function gmtvim {
	aliasRun { git mergetool --no-prompt --tool=vimdiff $args } $args
}
function gmum {
	$MainBranch = Get-Git-MainBranch

	aliasRun { git merge upstream/$MainBranch $args } $args
}
function gp {
	aliasRun { git push $args } $args
}
function gpd {
	aliasRun { git push --dry-run $args } $args
}
function gpf {
	aliasRun { git push --force-with-lease $args } $args
}
function gpf! {
	aliasRun { git push --force $args } $args
}
function gpoat {
	git push origin --all
	git push origin --tags
}
function gpristine {
	git reset --hard
	git clean -dfx
}
function gpu {
	aliasRun { git push upstream $args } $args
}
function gpv {
	aliasRun { git push -v $args } $args
}
function gr {
	aliasRun { git remote $args } $args
}
function gra {
	aliasRun { git remote add $args } $args
}
function grb {
	aliasRun { git rebase $args } $args
}
function grba {
	aliasRun { git rebase --abort $args } $args
}
function grbc {
	aliasRun { git rebase --continue $args } $args
}
function grbi {
	aliasRun { git rebase -i $args } $args
}
function grbm {
	$MainBranch = Get-Git-MainBranch

	aliasRun { git rebase $MainBranch $args } $args
}
function grbs {
	aliasRun { git rebase --skip $args } $args
}
function grh {
	aliasRun { git reset $args } $args
}
function grhh {
	aliasRun { git reset --hard $args } $args
}
function grmv {
	aliasRun { git remote rename $args } $args
}
function grrm {
	aliasRun { git remote remove $args } $args
}
function grs {
	aliasRun { git restore $args } $args
}
function grst {
	aliasRun { git restore --staged $args } $args
}
function grset {
	aliasRun { git remote set-url $args } $args
}
function grt {
	try {
		$RootPath = git rev-parse --show-toplevel
	}
	catch {
		$RootPath = "."
	}
	Set-Location $RootPath
}
function gru {
	aliasRun { git reset -- $args } $args
}
function grup {
	aliasRun { git remote update $args } $args
}
function grv {
	aliasRun { git remote -v $args } $args
}
function gsb {
	aliasRun { git status -sb $args } $args
}
function gsd {
	aliasRun { git svn dcommit $args } $args
}
function gsh {
	aliasRun { git show $args } $args
}
function gsi {
	aliasRun { git submodule init $args } $args
}
function gsps {
	aliasRun { git show --pretty=short --show-signature $args } $args
}
function gsr {
	aliasRun { git svn rebase $args } $args
}
function gss {
	aliasRun { git status -s $args } $args
}
function gst {
	aliasRun { git status $args } $args
}
function gsta {
	aliasRun { git stash save $args } $args
}
function gstaa {
	aliasRun { git stash apply $args } $args
}
function gstd {
	aliasRun { git stash drop $args } $args
}
function gstl {
	aliasRun { git stash list $args } $args
}
function gstp {
	aliasRun { git stash pop $args } $args
}
function gstc {
	aliasRun { git stash clear $args } $args
}
function gsts {
	aliasRun { git stash show --text $args } $args
}
function gsu {
	aliasRun { git submodule update $args } $args
}
function gsw {
	aliasRun { git switch $args } $args
}
function gts {
	aliasRun { git tag -s $args } $args
}
function gunignore {
	aliasRun { git update-index --no-assume-unchanged $args } $args
}
function gunwip {
	Write-Output $(git log -n 1 | Select-String "--wip--" -Quiet).Count
	git reset HEAD~1
}
function gup {
	aliasRun { git pull --rebase $args } $args
}
function gupv {
	aliasRun { git pull --rebase -v $args } $args
}
function glum {
	$MainBranch = Get-Git-MainBranch

	aliasRun { git pull upstream $MainBranch $args } $args
}
function gvt {
	aliasRun { git verify-tag $args } $args
}
function gwch {
	aliasRun { git whatchanged -p --abbrev-commit --pretty=medium $args } $args
}
function gwip {
	git add -A
	git rm $(git ls-files --deleted) 2> $null
	git commit --no-verify -m "--wip-- [skip ci]"
}
function ggl {
	$CurrentBranch = Get-Git-CurrentBranch

	git pull origin $CurrentBranch
}
function ggp {
	$CurrentBranch = Get-Git-CurrentBranch

	git push origin $CurrentBranch
}