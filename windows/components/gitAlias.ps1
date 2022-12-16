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

$script:alias_indicator = $true
$script:alias_indicator_color = "Yellow"

function g {
	aliasRun {git $args} $args $alias_indicator $alias_indicator_color
}
function ga {
	aliasRun {git add $args} $args $alias_indicator $alias_indicator_color
}
function gaa {
	aliasRun {git add --all $args} $args $alias_indicator $alias_indicator_color
}
function gapa {
	aliasRun {git add --patch $args} $args $alias_indicator $alias_indicator_color
}
function gau {
	aliasRun {git add --update $args} $args $alias_indicator $alias_indicator_color
}
function gav {
	aliasRun {git add --verbose $args} $args $alias_indicator $alias_indicator_color
}
function gb {
	aliasRun {git branch $args} $args $alias_indicator $alias_indicator_color
}
function gba {
	aliasRun {git branch -a $args} $args $alias_indicator $alias_indicator_color
}
function gbd {
	aliasRun {git branch -d $args} $args $alias_indicator $alias_indicator_color
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
	aliasRun {git blame -b -w $args} $args $alias_indicator $alias_indicator_color
}
function gbnm {
	aliasRun {git branch --no-merged $args} $args $alias_indicator $alias_indicator_color
}
function gbr {
	aliasRun {git branch --remote $args} $args $alias_indicator $alias_indicator_color
}
function gbs {
	aliasRun {git bisect $args} $args $alias_indicator $alias_indicator_color
}
function gbsb {
	aliasRun {git bisect bad $args} $args $alias_indicator $alias_indicator_color
}
function gbsg {
	aliasRun {git bisect good $args} $args $alias_indicator $alias_indicator_color
}
function gbsr {
	aliasRun {git bisect reset $args} $args $alias_indicator $alias_indicator_color
}
function gbss {
	aliasRun {git bisect start $args} $args $alias_indicator $alias_indicator_color
}
function gc {
	aliasRun {git commit -v $args} $args $alias_indicator $alias_indicator_color
}
function gc! {
	aliasRun {git commit -v --amend $args} $args $alias_indicator $alias_indicator_color
}
function gcn! {
	aliasRun {git commit -v --no-edit --amend $args} $args $alias_indicator $alias_indicator_color
}
function gca {
	aliasRun {git commit -v -a $args} $args $alias_indicator $alias_indicator_color
}
function gcam {
	aliasRun {git commit -a -m $args} $args $alias_indicator $alias_indicator_color
}
function gca! {
	aliasRun {git commit -v -a --amend $args} $args $alias_indicator $alias_indicator_color
}
function gcan! {
	aliasRun {git commit -v -a --no-edit --amend $args} $args $alias_indicator $alias_indicator_color
}
function gcans! {
	aliasRun {git commit -v -a -s --no-edit --amend $args} $args $alias_indicator $alias_indicator_color
}
function gcb {
	aliasRun {git checkout -b $args} $args $alias_indicator $alias_indicator_color
}
function gcf {
	aliasRun {git config --list $args} $args $alias_indicator $alias_indicator_color
}
function gcl {
	aliasRun {git clone --recursive $args} $args $alias_indicator $alias_indicator_color
}
function gclean {
	aliasRun {git clean -df $args} $args $alias_indicator $alias_indicator_color
}
function gcm {
	$MainBranch = Get-Git-MainBranch

	aliasRun {git checkout $MainBranch $args} $args $alias_indicator $alias_indicator_color
}
function gcd {
	aliasRun {git checkout develop $args} $args $alias_indicator $alias_indicator_color
}
function gcmsg {
	aliasRun {git commit -m $args} $args $alias_indicator $alias_indicator_color
}
function gco {
	aliasRun {git checkout $args} $args $alias_indicator $alias_indicator_color
}
function gcount {
	aliasRun {git shortlog -sn $args} $args $alias_indicator $alias_indicator_color
}
function gcp {
	aliasRun {git cherry-pick $args} $args $alias_indicator $alias_indicator_color
}
function gcpa {
	aliasRun {git cherry-pick --abort $args} $args $alias_indicator $alias_indicator_color
}
function gcpc {
	aliasRun {git cherry-pick --continue $args} $args $alias_indicator $alias_indicator_color
}
function gcs {
	aliasRun {git commit -S $args} $args $alias_indicator $alias_indicator_color
}
function gd {
	aliasRun {git diff $args} $args $alias_indicator $alias_indicator_color
}
function gdca {
	aliasRun {git diff --cached $args} $args $alias_indicator $alias_indicator_color
}
function gdt {
	aliasRun {git diff-tree --no-commit-id --name-only -r $args} $args $alias_indicator $alias_indicator_color
}
function gdw {
	aliasRun {git diff --word-diff $args} $args $alias_indicator $alias_indicator_color
}
function gf {
	aliasRun {git fetch $args} $args $alias_indicator $alias_indicator_color
}
function gfa {
	aliasRun {git fetch --all --prune $args} $args $alias_indicator $alias_indicator_color
}
function gfo {
	aliasRun {git fetch origin $args} $args $alias_indicator $alias_indicator_color
}
function gg {
	aliasRun {git gui citool $args} $args $alias_indicator $alias_indicator_color
}
function gga {
	aliasRun {git gui citool --amend $args} $args $alias_indicator $alias_indicator_color
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
	aliasRun {git help $args} $args $alias_indicator $alias_indicator_color
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
	aliasRun {git update-index --assume-unchanged $args} $args $alias_indicator $alias_indicator_color
}
function gignored {
	git ls-files -v | Select-String "^[a-z]" -CaseSensitive
}
function gl {
	aliasRun {git pull $args} $args $alias_indicator $alias_indicator_color
}
function glg {
	aliasRun {git log --stat --color $args} $args $alias_indicator $alias_indicator_color
}
function glgg {
	aliasRun {git log --graph --color $args} $args $alias_indicator $alias_indicator_color
}
function glgga {
	aliasRun {git log --graph --decorate --all $args} $args $alias_indicator $alias_indicator_color
}
function glgm {
	aliasRun {git log --graph --max-count=10 $args} $args $alias_indicator $alias_indicator_color
}
function glgp {
	aliasRun {git log --stat --color -p $args} $args $alias_indicator $alias_indicator_color
}
function glo {
	aliasRun {git log --oneline --decorate --color $args} $args $alias_indicator $alias_indicator_color
}
function glog {
	aliasRun {git log --oneline --decorate --color --graph $args} $args $alias_indicator $alias_indicator_color
}
function gloga {
	aliasRun {git log --oneline --decorate --color --graph --all $args} $args $alias_indicator $alias_indicator_color
}
function glol {
	aliasRun {git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $args} $args $alias_indicator $alias_indicator_color
}
function glola {
	aliasRun {git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all $args} $args $alias_indicator $alias_indicator_color
}
function gm {
	aliasRun {git merge $args} $args $alias_indicator $alias_indicator_color
}
function gmom {
	$MainBranch = Get-Git-MainBranch

	aliasRun {git merge origin/$MainBranch $args} $args $alias_indicator $alias_indicator_color
}
function gmt {
	aliasRun {git mergetool --no-prompt $args} $args $alias_indicator $alias_indicator_color
}
function gmtvim {
	aliasRun {git mergetool --no-prompt --tool=vimdiff $args} $args $alias_indicator $alias_indicator_color
}
function gmum {
	$MainBranch = Get-Git-MainBranch

	aliasRun {git merge upstream/$MainBranch $args} $args $alias_indicator $alias_indicator_color
}
function gp {
	aliasRun {git push $args} $args $alias_indicator $alias_indicator_color
}
function gpd {
	aliasRun {git push --dry-run $args} $args $alias_indicator $alias_indicator_color
}
function gpf {
	aliasRun {git push --force-with-lease $args} $args $alias_indicator $alias_indicator_color
}
function gpf! {
	aliasRun {git push --force $args} $args $alias_indicator $alias_indicator_color
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
	aliasRun {git push upstream $args} $args $alias_indicator $alias_indicator_color
}
function gpv {
	aliasRun {git push -v $args} $args $alias_indicator $alias_indicator_color
}
function gr {
	aliasRun {git remote $args} $args $alias_indicator $alias_indicator_color
}
function gra {
	aliasRun {git remote add $args} $args $alias_indicator $alias_indicator_color
}
function grb {
	aliasRun {git rebase $args} $args $alias_indicator $alias_indicator_color
}
function grba {
	aliasRun {git rebase --abort $args} $args $alias_indicator $alias_indicator_color
}
function grbc {
	aliasRun {git rebase --continue $args} $args $alias_indicator $alias_indicator_color
}
function grbi {
	aliasRun {git rebase -i $args} $args $alias_indicator $alias_indicator_color
}
function grbm {
	$MainBranch = Get-Git-MainBranch

	aliasRun {git rebase $MainBranch $args} $args $alias_indicator $alias_indicator_color
}
function grbs {
	aliasRun {git rebase --skip $args} $args $alias_indicator $alias_indicator_color
}
function grh {
	aliasRun {git reset $args} $args $alias_indicator $alias_indicator_color
}
function grhh {
	aliasRun {git reset --hard $args} $args $alias_indicator $alias_indicator_color
}
function grmv {
	aliasRun {git remote rename $args} $args $alias_indicator $alias_indicator_color
}
function grrm {
	aliasRun {git remote remove $args} $args $alias_indicator $alias_indicator_color
}
function grs {
	aliasRun {git restore $args} $args $alias_indicator $alias_indicator_color
}
function grset {
	aliasRun {git remote set-url $args} $args $alias_indicator $alias_indicator_color
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
	aliasRun {git reset -- $args} $args $alias_indicator $alias_indicator_color
}
function grup {
	aliasRun {git remote update $args} $args $alias_indicator $alias_indicator_color
}
function grv {
	aliasRun {git remote -v $args} $args $alias_indicator $alias_indicator_color
}
function gsb {
	aliasRun {git status -sb $args} $args $alias_indicator $alias_indicator_color
}
function gsd {
	aliasRun {git svn dcommit $args} $args $alias_indicator $alias_indicator_color
}
function gsh {
	aliasRun {git show $args} $args $alias_indicator $alias_indicator_color
}
function gsi {
	aliasRun {git submodule init $args} $args $alias_indicator $alias_indicator_color
}
function gsps {
	aliasRun {git show --pretty=short --show-signature $args} $args $alias_indicator $alias_indicator_color
}
function gsr {
	aliasRun {git svn rebase $args} $args $alias_indicator $alias_indicator_color
}
function gss {
	aliasRun {git status -s $args} $args $alias_indicator $alias_indicator_color
}
function gst {
	aliasRun {git status $args} $args $alias_indicator $alias_indicator_color
}
function gsta {
	aliasRun {git stash save $args} $args $alias_indicator $alias_indicator_color
}
function gstaa {
	aliasRun {git stash apply $args} $args $alias_indicator $alias_indicator_color
}
function gstd {
	aliasRun {git stash drop $args} $args $alias_indicator $alias_indicator_color
}
function gstl {
	aliasRun {git stash list $args} $args $alias_indicator $alias_indicator_color
}
function gstp {
	aliasRun {git stash pop $args} $args $alias_indicator $alias_indicator_color
}
function gstc {
	aliasRun {git stash clear $args} $args $alias_indicator $alias_indicator_color
}
function gsts {
	aliasRun {git stash show --text $args} $args $alias_indicator $alias_indicator_color
}
function gsu {
	aliasRun {git submodule update $args} $args $alias_indicator $alias_indicator_color
}
function gsw {
	aliasRun {git switch $args} $args $alias_indicator $alias_indicator_color
}
function gts {
	aliasRun {git tag -s $args} $args $alias_indicator $alias_indicator_color
}
function gunignore {
	aliasRun {git update-index --no-assume-unchanged $args} $args $alias_indicator $alias_indicator_color
}
function gunwip {
	Write-Output $(git log -n 1 | Select-String "--wip--" -Quiet).Count
	git reset HEAD~1
}
function gup {
	aliasRun {git pull --rebase $args} $args $alias_indicator $alias_indicator_color
}
function gupv {
	aliasRun {git pull --rebase -v $args} $args $alias_indicator $alias_indicator_color
}
function glum {
	$MainBranch = Get-Git-MainBranch

	aliasRun {git pull upstream $MainBranch $args} $args $alias_indicator $alias_indicator_color
}
function gvt {
	aliasRun {git verify-tag $args} $args $alias_indicator $alias_indicator_color
}
function gwch {
	aliasRun {git whatchanged -p --abbrev-commit --pretty=medium $args} $args $alias_indicator $alias_indicator_color
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