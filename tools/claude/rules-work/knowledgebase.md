<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Knowledgebase Vault](#knowledgebase-vault)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Knowledgebase Vault

Personal engineering knowledgebase (Obsidian vault). The path is set per-profile
by `.envrc` in this dotfiles repo as the `CLAUDE_VAULT_DIR` env var:

- `work` profile: `$HOME/source/work/knowledgebase`
- `personal` profile: `$HOME/knowledgebase`

Regardless of which repo a session starts in, check `$CLAUDE_VAULT_DIR` first
for prior context on tickets, incidents, endpoints, AWS account/profile
mappings, indexed repository notes (`repositories/<repo-name>.md`), etc.
before re-deriving it.

The vault may not be cloned yet on every machine. If `$CLAUDE_VAULT_DIR` is
unset or the directory does not exist, skip this step and proceed without it;
do not try to create it.
