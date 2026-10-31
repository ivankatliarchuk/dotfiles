<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Step 1: Read the rules first](#step-1-read-the-rules-first)
- [Step 2: Explore the repo](#step-2-explore-the-repo)
- [Step 3: Show the entry before writing](#step-3-show-the-entry-before-writing)
- [Step 4: Write](#step-4-write)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Create or update a knowledgebase repository index entry conforming to the blueprint.

Input: $ARGUMENTS is an optional repo path or name. If empty, index the repository in the current working directory.

Vault: `${CLAUDE_VAULT_DIR:-$HOME/knowledgebase}`. Entries live in `repositories/<repo-name>.md` and are listed in `repositories/index.md`.

## Step 1: Read the rules first

- Read `${CLAUDE_VAULT_DIR:-$HOME/knowledgebase}/repositories/index-repo-blueprint.md` and follow it exactly: frontmatter, the template sections, "What NOT to include", and the index.md format.
- Read the vault root `CLAUDE.md` for the Frontmatter Convention (title, one-line summary, exactly 5 lowercase tags, ISO `date` and `updated`).
- Check whether `repositories/<repo-name>.md` already exists. If it does, this is an update: keep past Q&A rows and fix only what is stale. Do not rewrite history.

## Step 2: Explore the repo

You are allowed to run read-only commands (`git remote -v`, `git log`, `ls`, `grep`, `find`, reading files) without asking, because the operator explicitly invoked this command.

Collect the facts the blueprint asks for: remote URL, absolute local path, purpose, owner, product and Jira identifiers, structure, key concepts, configuration, where secrets come from, entry points, environments, CI/CD, tech stack, and the non-obvious gotchas. The gotchas section is the most valuable part, so spend effort there.

Do not include secret values, anything that will rot within a week, or paraphrases of readable code.

## Step 3: Show the entry before writing

Print the complete entry and the single `index.md` line you would add, filed under the best-fitting heading. Wait for my approval. Do not write anything until I say so.

## Step 4: Write

On approval, write `repositories/<repo-name>.md` and add the line to `repositories/index.md`. Do not commit or push the knowledgebase.
