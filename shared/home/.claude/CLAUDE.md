# Global Claude Configuration

## Behavior

Do not assume intent when something is unclear — ask for direction instead. Do not add
defensive fallbacks, extra aliases, helper functions, or "improvements" beyond what was
requested. When adapting existing patterns (e.g. porting dotfiles to a new platform),
mirror the existing approach closely and ask before deviating.

## Git Commits

Do not include a Co-Authored-By trailer in commit messages. The engineer directing AI
takes full ownership of commits — attribution is to the git user, not the AI.

## Dotfiles

Global Claude configuration (`~/.claude/CLAUDE.md`) is tracked in the dotfiles repo at
`~/dotfiles/shared/home/.claude/`. Platform-specific Claude settings (`~/.claude/settings.json`)
remain in each platform's directory.

These are copies, not symlinks. When modifying global claude config:
1. Edit the file in `~/.claude/`
2. Copy the updated file to `~/dotfiles/shared/home/.claude/`
3. Commit the change in the dotfiles repo
