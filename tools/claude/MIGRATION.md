<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Migrating `~/.claude` from whole-dir symlink to real directory](#migrating-claude-from-whole-dir-symlink-to-real-directory)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
  - [Verifying](#verifying)
  - [Cleanup](#cleanup)
  - [If something went wrong](#if-something-went-wrong)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Migrating `~/.claude` from whole-dir symlink to real directory

An earlier version of this repo deployed Claude Code's config by making
`~/.claude` a single symlink into `tools/claude/`. That worked for a single
machine but broke on a work Mac where Tech Pass owns `~/.claude/CLAUDE.md`
and `~/.claude/settings.json`: their local edits propagated into the repo.

The current setup replaces that with:

- Per-file symlinks into the repo for shared, versioned content:
  `CLAUDE.local.md`, `statusline-command.sh`, `commands/`.
- Copies (not symlinks) seeded on personal machines only, so later edits
  stay local: `CLAUDE.md` (from `tools/claude/CLAUDE.personal.md`) and
  `settings.json` (from `tools/claude/settings.local.json`).
- `~/.claude/` as a real directory on every machine, holding Claude Code's
  own runtime data (`projects/`, `history.jsonl`, `plugins/`, `backups/`,
  `cache/`, `sessions/`, `skills/`, `tasks/`, etc.) directly.

`bin/install` refuses to run while `~/.claude` is still the old symlink,
to prevent `mise bootstrap dotfiles apply --force` from clobbering repo
contents with self-referential symlinks. This guide is how you clear that
block, once per machine.

## Prerequisites

1. Quit every Claude Code session (CLI, VS Code extension, desktop app).
2. Know the repo path on this machine. On personal it is usually
   `~/source/dotfiles`; on work it may be `~/source/self/dotfiles`.
3. If this is the work Mac, decide whether Tech Pass's current
   `~/.claude/CLAUDE.md` and `~/.claude/settings.json` content must be
   preserved. If yes, this guide keeps them.

## Steps

Run these as yourself, not sudo. Replace the repo path on the last line
if it differs on this machine.

```
BACKUP=~/.claude-migrate-$(date +%Y%m%d-%H%M%S)

# 1. Capture the real content behind the symlink (follow -L).
rsync -aL ~/.claude/ "$BACKUP/"

# 2. Replace the symlink with a real directory using the snapshot.
rm ~/.claude
mv "$BACKUP" ~/.claude

# 3. Remove the repo-managed names from the restored copy so mise can
#    place its symlinks cleanly on top. These are either tracked and will
#    be re-created, or they are placeholders you do not want in ~/.claude/.
rm -f  ~/.claude/CLAUDE.local.md ~/.claude/statusline-command.sh \
       ~/.claude/CLAUDE.personal.md ~/.claude/settings.local.json
rm -rf ~/.claude/commands

# 4. On work machines only: set the profile so bin/install does NOT copy
#    personal placeholders over Tech Pass's local CLAUDE.md / settings.json.
#    Set it per-shell for this run, or make it permanent via .envrc / Keychain.
export DOTFILES_PROFILE=work   # omit on personal; the default is "personal"

# 5. Run the installer. The guard rail now passes.
cd ~/source/dotfiles && make install   # adjust path if different on this box
```

## Verifying

```
test -d ~/.claude && ! test -L ~/.claude && echo "ok: real directory"
file ~/.claude/CLAUDE.md ~/.claude/settings.json
file ~/.claude/CLAUDE.local.md ~/.claude/statusline-command.sh ~/.claude/commands
ls ~/.claude/projects ~/.claude/history.jsonl 2>/dev/null
```

Expected:
- `~/.claude/`: real directory.
- `~/.claude/CLAUDE.md`, `~/.claude/settings.json`: plain files (either Tech
  Pass's existing content on work, or copies of the placeholders on personal).
- `~/.claude/CLAUDE.local.md`, `~/.claude/statusline-command.sh`,
  `~/.claude/commands`: symbolic links into the repo.
- `~/.claude/projects`, `~/.claude/history.jsonl`: still there.

## Cleanup

Keep the timestamped `~/.claude-migrate-*` backup for a day in case anything
looks off, then `rm -rf` it.

## If something went wrong

- `mise bootstrap dotfiles status` lists every target with its current state;
  "differs" or "missing" lines show what still needs attention.
- The guard rail only checks for `~/.claude` being a symlink. If the real
  directory ends up with repo-managed files leaked in, remove just those
  file names from `~/.claude/` and rerun `make install`.
- Nothing in this migration touches the repo working tree. If a step fails,
  the repo state is still exactly what `git status` reported before you
  started.
