. $PSScriptRoot\poshGAliasList.ps1

$script:gitCommandsWithLongParams = "$($longGitParams.Keys -join '|')|$($gitAliasesWithLongParams)"
$script:gitCommandsWithShortParams = "$($shortGitParams.Keys -join '|')|$($gitAliasesWithShortParams)"
$script:gitCommandsWithParamValues = $gitParamValues.Keys -join '|'
$script:vstsCommandsWithShortParams = $shortVstsParams.Keys -join '|'
$script:vstsCommandsWithLongParams = $longVstsParams.Keys -join '|'

$script:gitAliases = $poshGitAliasList.Keys -join '|'
$script:gitAliasesWithLongParams = ($poshGitAliasMap.Keys | Where-Object {$longGitParams.Keys.Contains($_)}) -join '|'
$script:gitAliasesWithShortParams = ($poshGitAliasMap.Keys | Where-Object {$shortGitParams.Keys.Contains($_)}) -join '|'

Write-Host $gitAliasesWithLongParams -ForegroundColor "Yellow"
Write-Host $gitAliasesWithShortParams -ForegroundColor "Yellow"

filter quoteStringWithSpecialChars {
    if ($_ -and ($_ -match '\s+|#|@|\$|;|,|''|\{|\}|\(|\)')) {
        $str = $_ -replace "'", "''"
        "'$str'"
    }
    else {
        $_
    }
}

function script:gitCommands($filter, $includeAliases) {
    $cmdList = @()
    if (-not $global:GitTabSettings.AllCommands) {
        $cmdList += $someCommands -like "$filter*"
    }
    else {
        $cmdList += git help --all |
        Where-Object { $_ -match '^\s{2,}\S.*' } |
        ForEach-Object { $_.Split(' ', [StringSplitOptions]::RemoveEmptyEntries) } |
        Where-Object { $_ -like "$filter*" }
    }

    if ($includeAliases) {
        $cmdList += gitAliases $filter
    }

    $cmdList | Sort-Object
}

function script:gitRemotes($filter) {
    git remote |
    Where-Object { $_ -like "$filter*" } |
    quoteStringWithSpecialChars
}

function script:gitBranches($filter, $includeHEAD = $false, $prefix = '') {
    if ($filter -match "^(?<from>\S*\.{2,3})(?<to>.*)") {
        $prefix += $matches['from']
        $filter = $matches['to']
    }

    $branches = @(git branch --no-color | ForEach-Object { if (($_ -notmatch "^\* \(HEAD detached .+\)$") -and ($_ -match "^[\*\+]?\s*(?<ref>\S+)(?: -> .+)?")) { $matches['ref'] } }) +
    @(git branch --no-color -r | ForEach-Object { if ($_ -match "^  (?<ref>\S+)(?: -> .+)?") { $matches['ref'] } }) +
    @(if ($includeHEAD) { 'HEAD', 'FETCH_HEAD', 'ORIG_HEAD', 'MERGE_HEAD' })

    $branches |
    Where-Object { $_ -ne '(no branch)' -and $_ -like "$filter*" } |
    ForEach-Object { $prefix + $_ } |
    quoteStringWithSpecialChars
}

function script:gitRemoteUniqueBranches($filter) {
    git branch --no-color -r |
    ForEach-Object { if ($_ -match "^  (?<remote>[^/]+)/(?<branch>\S+)(?! -> .+)?$") { $matches['branch'] } } |
    Group-Object -NoElement |
    Where-Object { $_.Count -eq 1 } |
    Select-Object -ExpandProperty Name |
    Where-Object { $_ -like "$filter*" } |
    quoteStringWithSpecialChars
}

function script:gitConfigKeys($section, $filter, $defaultOptions = '') {
    $completions = @($defaultOptions -split ' ')

    git config --name-only --get-regexp ^$section\..* |
    ForEach-Object { $completions += ($_ -replace "$section\.", "") }

    return $completions |
    Where-Object { $_ -like "$filter*" } |
    Sort-Object |
    quoteStringWithSpecialChars
}

function script:gitTags($filter, $prefix = '') {
    git tag |
    Where-Object { $_ -like "$filter*" } |
    ForEach-Object { $prefix + $_ } |
    quoteStringWithSpecialChars
}

function script:gitFeatures($filter, $command) {
    $featurePrefix = git config --local --get "gitflow.prefix.$command"
    $branches = @(git branch --no-color | ForEach-Object { if ($_ -match "^\*?\s*$featurePrefix(?<ref>.*)") { $matches['ref'] } })
    $branches |
    Where-Object { $_ -ne '(no branch)' -and $_ -like "$filter*" } |
    ForEach-Object { $featurePrefix + $_ } |
    quoteStringWithSpecialChars
}

function script:gitRemoteBranches($remote, $ref, $filter, $prefix = '') {
    git branch --no-color -r |
    Where-Object { $_ -like "  $remote/$filter*" } |
    ForEach-Object { $prefix + $ref + ($_ -replace "  $remote/", "") } |
    quoteStringWithSpecialChars
}

function script:gitStashes($filter) {
    (git stash list) -replace ':.*', '' |
    Where-Object { $_ -like "$filter*" } |
    quoteStringWithSpecialChars
}

function script:gitTfsShelvesets($filter) {
    (git tfs shelve-list) |
    Where-Object { $_ -like "$filter*" } |
    quoteStringWithSpecialChars
}

function script:gitFiles($filter, $files) {
    $files | Sort-Object |
    Where-Object { $_ -like "$filter*" } |
    quoteStringWithSpecialChars
}

function script:gitIndex($GitStatus, $filter) {
    gitFiles $filter $GitStatus.Index
}

function script:gitAddFiles($GitStatus, $filter) {
    gitFiles $filter (@($GitStatus.Working.Unmerged) + @($GitStatus.Working.Modified) + @($GitStatus.Working.Added))
}

function script:gitCheckoutFiles($GitStatus, $filter) {
    gitFiles $filter (@($GitStatus.Working.Unmerged) + @($GitStatus.Working.Modified) + @($GitStatus.Working.Deleted))
}

function script:gitDeleted($GitStatus, $filter) {
    gitFiles $filter $GitStatus.Working.Deleted
}

function script:gitDiffFiles($GitStatus, $filter, $staged) {
    if ($staged) {
        gitFiles $filter $GitStatus.Index.Modified
    }
    else {
        gitFiles $filter (@($GitStatus.Working.Unmerged) + @($GitStatus.Working.Modified) + @($GitStatus.Index.Modified))
    }
}

function script:gitMergeFiles($GitStatus, $filter) {
    gitFiles $filter $GitStatus.Working.Unmerged
}

function script:gitRestoreFiles($GitStatus, $filter, $staged) {
    if ($staged) {
        gitFiles $filter (@($GitStatus.Index.Added) + @($GitStatus.Index.Modified) + @($GitStatus.Index.Deleted))
    }
    else {
        gitFiles $filter (@($GitStatus.Working.Unmerged) + @($GitStatus.Working.Modified) + @($GitStatus.Working.Deleted))
    }
}

function script:gitAliases($filter) {
    git config --get-regexp ^alias\. | ForEach-Object {
        if ($_ -match "^alias\.(?<alias>\S+) .*") {
            $alias = $Matches['alias']
            if ($alias -like "$filter*") {
                $alias
            }
        }
    } | Sort-Object -Unique
}

function script:expandGitAlias($cmd, $rest) {
    $alias = git config "alias.$cmd"

    if ($alias) {
        $known = $Global:GitTabSettings.KnownAliases[$alias]
        if ($known) {
            return "git $known$rest"
        }

        return "git $alias$rest"
    }
    else {
        return "git $cmd$rest"
    }
}

function script:expandLongParams($hash, $cmd, $filter) {
    $hash[$cmd].Trim() -split ' ' |
    Where-Object { $_ -like "$filter*" } |
    Sort-Object |
    ForEach-Object { -join ("--", $_) }
}

function script:expandShortParams($hash, $cmd, $filter) {
    $hash[$cmd].Trim() -split ' ' |
    Where-Object { $_ -like "$filter*" } |
    Sort-Object |
    ForEach-Object { -join ("-", $_) }
}

function script:expandParamValues($cmd, $param, $filter) {
    $paramValues = $gitParamValues[$cmd][$param]

    $completions = if ($paramValues -is [scriptblock]) {
        & $paramValues $filter
    }
    else {
        $paramValues.Trim() -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object
    }

    $completions | ForEach-Object { -join ("--", $param, "=", $_) }
}

function Invoke-Utf8ConsoleCommand ([ScriptBlock]$cmd) {
    $currentEncoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
        & $cmd
    }
    finally {
        [Console]::OutputEncoding = $currentEncoding
    }
}

function Expand-GitCommand2($Command) {
    # Parse all Git output as UTF8, including tab completion output - https://github.com/dahlbyk/posh-git/pull/359
    $res = Invoke-Utf8ConsoleCommand { GitTabExpansionInternalB $Command $Global:GitStatus }
    $res
}

function GitTabExpansionInternalB($lastBlock, $GitStatus = $null) {
    $ignoreGitParams = '(?<params>\s+-(?:[aA-zZ0-9]+|-[aA-zZ0-9][aA-zZ0-9-]*)(?:=\S+)?)*'

    # if ($lastBlock -match "^g(.*)(?<cmd>\S+)(?<args> .*)$") {
    #     $lastBlock = expandGitAlias $Matches['cmd'] $Matches['args']
    # }
    
    switch -regex ($lastBlock -replace "^$g", "") {
        # # Handles git <cmd> <op>
        # "^(?<cmd>$($subcommands.Keys -join '|'))\s+(?<op>\S*)$" {
        #     gitCmdOperations $subcommands $matches['cmd'] $matches['op']
        # }

        # # Handles git flow <cmd> <op>
        # "^flow (?<cmd>$($gitflowsubcommands.Keys -join '|'))\s+(?<op>\S*)$" {
        #     gitCmdOperations $gitflowsubcommands $matches['cmd'] $matches['op']
        # }

        # # Handles git flow <command> <op> <name>
        # "^flow (?<command>\S*)\s+(?<op>\S*)\s+(?<name>\S*)$" {
        #     gitFeatures $matches['name'] $matches['command']
        # }

        # # Handles git remote (rename|rm|set-head|set-branches|set-url|show|prune) <stash>
        # "^remote.* (?:rename|rm|set-head|set-branches|set-url|show|prune).* (?<remote>\S*)$" {
        #     gitRemotes $matches['remote']
        # }

        # # Handles git stash (show|apply|drop|pop|branch) <stash>
        # "^stash (?:show|apply|drop|pop|branch).* (?<stash>\S*)$" {
        #     gitStashes $matches['stash']
        # }

        # # Handles git bisect (bad|good|reset|skip) <ref>
        # "^bisect (?:bad|good|reset|skip).* (?<ref>\S*)$" {
        #     gitBranches $matches['ref'] $true
        # }

        # # Handles git tfs unshelve <shelveset>
        # "^tfs +unshelve.* (?<shelveset>\S*)$" {
        #     gitTfsShelvesets $matches['shelveset']
        # }

        # # Handles git branch -d|-D|-m|-M <branch name>
        # # Handles git branch <branch name> <start-point>
        # "^branch.* (?<branch>\S*)$" {
        #     gitBranches $matches['branch']
        # }

        # # Handles git <cmd> (commands & aliases)
        # "^(?<cmd>\S*)$" {
        #     gitCommands $matches['cmd'] $TRUE
        # }

        # # Handles git help <cmd> (commands only)
        # "^help (?<cmd>\S*)$" {
        #     gitCommands $matches['cmd'] $FALSE
        # }

        # # Handles git push remote <ref>:<branch>
        # # Handles git push remote +<ref>:<branch>
        # "^push${ignoreGitParams}\s+(?<remote>[^\s-]\S*).*\s+(?<force>\+?)(?<ref>[^\s\:]*\:)(?<branch>\S*)$" {
        #     gitRemoteBranches $matches['remote'] $matches['ref'] $matches['branch'] -prefix $matches['force']
        # }

        # # Handles git push remote <ref>
        # # Handles git push remote +<ref>
        # # Handles git pull remote <ref>
        # "^(?:push|pull)${ignoreGitParams}\s+(?<remote>[^\s-]\S*).*\s+(?<force>\+?)(?<ref>[^\s\:]*)$" {
        #     gitBranches $matches['ref'] -prefix $matches['force']
        #     gitTags $matches['ref'] -prefix $matches['force']
        # }

        # # Handles git pull <remote>
        # # Handles git push <remote>
        # # Handles git fetch <remote>
        # "^(?:push|pull|fetch)${ignoreGitParams}\s+(?<remote>\S*)$" {
        #     gitRemotes $matches['remote']
        # }

        # # Handles git reset HEAD <path>
        # # Handles git reset HEAD -- <path>
        # "^reset.* HEAD(?:\s+--)? (?<path>\S*)$" {
        #     gitIndex $GitStatus $matches['path']
        # }

        # # Handles git <cmd> <ref>
        # "^commit.*-C\s+(?<ref>\S*)$" {
        #     gitBranches $matches['ref'] $true
        # }

        # # Handles git add <path>
        # "^add.* (?<files>\S*)$" {
        #     gitAddFiles $GitStatus $matches['files']
        # }

        # # Handles git checkout -- <path>
        # "^checkout.* -- (?<files>\S*)$" {
        #     gitCheckoutFiles $GitStatus $matches['files']
        # }

        # # Handles git restore -s <ref> / --source=<ref> - must come before the next regex case
        # "^restore.* (?-i)(-s\s*|(?<source>--source=))(?<ref>\S*)$" {
        #     gitBranches $matches['ref'] $true $matches['source']
        #     gitTags $matches['ref']
        #     break
        # }

        # # Handles git restore <path>
        # "^restore(?:.* (?<staged>(?:(?-i)-S|--staged))|.*) (?<files>\S*)$" {
        #     gitRestoreFiles $GitStatus $matches['files'] $matches['staged']
        # }

        # # Handles git rm <path>
        # "^rm.* (?<index>\S*)$" {
        #     gitDeleted $GitStatus $matches['index']
        # }

        # # Handles git diff/difftool <path>
        # "^(?:diff|difftool)(?:.* (?<staged>(?:--cached|--staged))|.*) (?<files>\S*)$" {
        #     gitDiffFiles $GitStatus $matches['files'] $matches['staged']
        # }

        # # Handles git merge/mergetool <path>
        # "^(?:merge|mergetool).* (?<files>\S*)$" {
        #     gitMergeFiles $GitStatus $matches['files']
        # }

        # # Handles git checkout|switch <ref>
        # "^(?:checkout|switch).* (?<ref>\S*)$" {
        #     & {
        #         gitBranches $matches['ref'] $true
        #         gitRemoteUniqueBranches $matches['ref']
        #         gitTags $matches['ref']
        #         # Return only unique branches (to eliminate duplicates where the branch exists locally and on the remote)
        #     } | Select-Object -Unique
        # }

        # Handles git worktree add <path> <ref>
        # "^worktree add.* (?<files>\S+) (?<ref>\S*)$" {
        #     gitBranches $matches['ref']
        # }

        # # Handles git <cmd> <ref>
        # "^(?:cherry|cherry-pick|diff|difftool|log|merge|rebase|reflog\s+show|reset|revert|show).* (?<ref>\S*)$" {
        #     gitBranches $matches['ref'] $true
        #     gitTags $matches['ref']
        # }

        # # Handles git <cmd> --<param>=<value>
        # "^(?<cmd>$gitCommandsWithParamValues).* --(?<param>[^=]+)=(?<value>\S*)$" {
        #     expandParamValues $matches['cmd'] $matches['param'] $matches['value']
        # }

        # # Handles git <cmd> --<param>
        # "^(?<cmd>$gitCommandsWithLongParams).* --(?<param>\S*)$" {
        #     expandLongParams $longGitParams $matches['cmd'] $matches['param']
        # }

        # # Handles git <cmd> -<shortparam>
        # "^(?<cmd>$gitCommandsWithShortParams).* -(?<shortparam>\S*)$" {
        #     expandShortParams $shortGitParams $matches['cmd'] $matches['shortparam']
        # }

        # # Handles git pr alias
        # "vsts\.pr\s+(?<op>\S*)$" {
        #     gitCmdOperations $subcommands 'vsts.pr' $matches['op']
        # }

        # # Handles git pr <cmd> --<param>
        # "vsts\.pr\s+(?<cmd>$vstsCommandsWithLongParams).*--(?<param>\S*)$"
        # {
        #     expandLongParams $longVstsParams $matches['cmd'] $matches['param']
        # }

        # # Handles git pr <cmd> -<shortparam>
        # "vsts\.pr\s+(?<cmd>$vstsCommandsWithShortParams).*-(?<shortparam>\S*)$"
        # {
        #     expandShortParams $shortVstsParams $matches['cmd'] $matches['shortparam']
        # }

        # git add <files>
        "^ga.* (?<files>\S*)$" {
            gitAddFiles $GitStatus $matches['files']
        }
        # git checkout <ref>
        "^gco.* (?<ref>\S*)$" {
            & {
                gitBranches $matches['ref'] $true
                gitRemoteUniqueBranches $matches['ref']
                gitTags $matches['ref']
                # Return only unique branches (to eliminate duplicates where the branch exists locally and on the remote)
            } | Select-Object -Unique
        }

        # Handles git <cmd> --<param>
        "^(?<cmd>$gitAliasesWithLongParams).* --(?<param>\S*)$" {
            expandLongParams $longGitParams $poshGitAliasMap[$matches['cmd']] $matches['param']
        }

        # Handles git <cmd> -<shortparam>
        "^(?<cmd>$gitAliasesWithShortParams).* -(?<shortparam>\S*)$" {
            expandShortParams $shortGitParams $poshGitAliasMap[$matches['cmd']] $matches['shortparam']
        }
    }
}

function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

    switch -regex ($lastBlock) {
        # Execute git tab completion for all git-related commands
        "^$($gitAliases) (.*)" { GitTabExpansionInternalB $lastBlock $Global:GitStatus }
        # "^$(Get-AliasPattern git) (.*)" { WriteTabExpLog $msg; Expand-GitCommand $lastBlock }
        # "^$(Get-AliasPattern tgit) (.*)" { WriteTabExpLog $msg; Expand-GitCommand $lastBlock }
        # "^$(Get-AliasPattern gitk) (.*)" { WriteTabExpLog $msg; Expand-GitCommand $lastBlock }
    }
}
