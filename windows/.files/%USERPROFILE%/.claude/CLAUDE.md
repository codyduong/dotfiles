# Global Claude Configuration

## Git Commits

Do not include a Co-Authored-By trailer in commit messages. The engineer directing AI
takes full ownership of commits — attribution is to the git user, not the AI.

## Dotfiles

Global Claude configuration files (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`) are
tracked in the dotfiles repo at `~/dotfiles/windows/.files/%USERPROFILE%/.claude/`.

These are copies, not symlinks. When modifying global claude config:
1. Edit the file in `~/.claude/`
2. Copy the updated file to `~/dotfiles/windows/.files/%USERPROFILE%/.claude/`
3. Commit the change in the dotfiles repo (branch pattern: version numbers like `1.13.0`)
