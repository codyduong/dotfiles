from thefuck.types import Command
from thefuck.rules import (
    git_add,
    git_add_force,
    git_bisect_usage,
    git_push,
    git_push_different_branch_names,
    git_push_force,
    git_push_pull,
    git_push_without_commits,
)


ALIAS_LIST_RULES = {
    "add": [
        [git_add.match, git_add.get_new_command],
        [git_add_force.match, git_add_force.get_new_command],
    ],
    "bisect": [[git_bisect_usage.match, git_bisect_usage.get_new_command]],
    "push": [
        [git_push.match, git_push.get_new_command],
        [
            git_push_different_branch_names.match,
            git_push_different_branch_names.get_new_command,
        ],
        [git_push_force.match, git_push_force.get_new_command],
        [git_push_pull.match, git_push_pull.get_new_command],
        [git_push_without_commits.match, git_push_without_commits.get_new_command],
    ],
}


ALIAS_LIST = {
    "ga": ["git add", ALIAS_LIST_RULES["add"]],
    "gaa": ["git add --all", ALIAS_LIST_RULES["add"]],
    "gapa": ["git add --patch", ALIAS_LIST_RULES["add"]],
    "gau": ["git add --update", ALIAS_LIST_RULES["add"]],
    "gav": ["git add --verbose", ALIAS_LIST_RULES["add"]],
    "gp": ["git push", ALIAS_LIST_RULES["push"]],
    "gpd": ["git push --dry-run", ALIAS_LIST_RULES["push"]],
    "gpf!": ["git push --force", ALIAS_LIST_RULES["push"]],
}


def _generate_unalias_command(command):
    global git_alias_corrections

    # replace the corrected value
    if len(git_alias_corrections) == 0:
        new_command_parts = []
        rules = None
        for part in command.script_parts:
            if part in ALIAS_LIST.keys():
                new_command_parts.append(ALIAS_LIST[part][0])
                rules = ALIAS_LIST[part][1]
            else:
                new_command_parts += part
        new_command = Command.from_raw_script(new_command_parts)
        # go through other rule matches and get_new_command
        for rule in rules:
            if rule[0](new_command):
                git_alias_corrections.append(rule[1](new_command))
    return git_alias_corrections


def match(command):
    global git_alias_corrections
    git_alias_corrections = []
    return len(_generate_unalias_command(command)) > 0


def get_new_command(command):
    return _generate_unalias_command(command)
