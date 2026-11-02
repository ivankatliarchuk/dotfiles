<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Git Platform Detection](#git-platform-detection)
- [Git Operations](#git-operations)
- [GitLab MR Replies](#gitlab-mr-replies)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Git Platform Detection

Before using any Git hosting tool (`gh` or `glab`), you MUST:

1. Read `.git/config` in the current working directory
2. If the remote URL contains `git.tmaws.io` -> use `glab` (GitLab CLI)
3. If the remote URL contains `github.com` -> use `gh` CLI
4. If `.git/config` is absent, unreadable, or the remote URL matches neither -> ask the user whether to use `gh` or `glab` before proceeding

# Git Operations

You MUST NEVER push, commit, or edit files in a git repository unless the user explicitly asks you to. This applies to both GitHub (`gh`) and GitLab (`glab`).

# GitLab MR Replies

When replying to comments/discussions on a GitLab MR, you may only reply to threads authored by `review-bot`. You must NEVER reply to a human reviewer's comment, under any circumstances. Before posting any reply to review-bot, show the drafted reply text in the terminal and wait for explicit approval - do not post automatically.
