<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Step 1: Locate the change and the findings](#step-1-locate-the-change-and-the-findings)
- [Step 2: Verify before trusting](#step-2-verify-before-trusting)
- [Step 3: Triage each finding](#step-3-triage-each-finding)
- [Step 4: Draft replies and wait for approval](#step-4-draft-replies-and-wait-for-approval)
- [Step 5: Gate on commit and push](#step-5-gate-on-commit-and-push)
- [Step 6: Post approved replies and resolve](#step-6-post-approved-replies-and-resolve)
- [Step 7: Summarize](#step-7-summarize)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Address ReviewBot findings on a pull or merge request: triage each one, fix what's real, verify claims first, then draft short replies and wait for approval before posting anything.

Input: $ARGUMENTS is a PR or MR number or full URL. If it is empty, use the change for the current branch (`gh pr view` or `glab mr view`), or ask.

Detect the host from `git config --get remote.origin.url`: use `gh` for `github.com` and `glab --hostname <host>` otherwise. The bot username defaults to `review-bot`; override via `$REVIEW_BOT_USER` if your bot has a different handle.

You are allowed to run read-only git and host-CLI commands without asking, because the operator explicitly invoked this command: `git branch --show-current`, `git status`, `git diff`, `git log`, `gh pr view / glab mr view`, `gh auth status / glab auth status`, and GET-only `gh api` / `glab api` calls. Never commit, push, post, or resolve anything without the approval described below.

## Step 1: Locate the change and the findings

- Confirm the host from `.git/config`. The chosen CLI must already be authenticated.
- Compare `git branch --show-current` with the change's source branch. If they differ, tell me and ask whether to continue.
- Fetch every discussion. On GitHub use `gh api repos/<owner>/<repo>/pulls/<n>/comments --paginate`. On GitLab use `glab api --hostname <host> "projects/<url-encoded-path>/merge_requests/<mr>/discussions?per_page=100&page=<n>"` and loop pages until one returns fewer than 100 items, because the default of 20 silently drops threads.
- Keep only threads authored by `${REVIEW_BOT_USER:-review-bot}`. Ignore every human reviewer's thread. Never reply to a human.
- Show a table of findings, most severe first, with columns Severity, File:Line, Description.

## Step 2: Verify before trusting

ReviewBot is sometimes confidently wrong. Before fixing or conceding any finding that makes a technical claim, grep the codebase or run a small scratch test to confirm it. Do not accept a checkable claim on ReviewBot's word alone.

## Step 3: Triage each finding

1. Real and actionable: make the minimal fix.
2. Real but intentional: no change, reply with the reason.
3. False positive: no change, reply with the evidence.
4. Out of scope: no change now, reply that it is deferred.

After each fix, re-validate (`terraform fmt -check` and `terraform validate`, `python -m py_compile` plus the relevant tests, or the language's standard checks). If a pattern appears in several places, fix all of them or explain why one differs.

Any comment you add in code must be one line and at most 15 words.

## Step 4: Draft replies and wait for approval

Draft one reply per finding. Each reply is at most 15 words, states the verdict plainly (fixed, intentional, false positive, deferred), and uses no em dashes. Show all drafts together in the terminal. Do not post anything yet. Wait for my explicit approval, per thread or all at once, and redraft if I ask for edits.

## Step 5: Gate on commit and push

Do not post or resolve anything until I confirm the fix commits are committed and pushed to the MR branch. Do not commit or push on your own.

## Step 6: Post approved replies and resolve

For each approved reply only, post it with the detected CLI:
- GitHub: `gh api repos/<owner>/<repo>/pulls/<n>/comments/<id>/replies -X POST -f "body=<reply>"`, then resolve the thread via the PR review UI or `gh api .../pulls/comments/<id>` as applicable.
- GitLab: `glab api --hostname <host> projects/<path>/merge_requests/<mr>/discussions/<id>/notes -X POST -f "body=<reply>"`, then resolve with `glab api --hostname <host> projects/<path>/merge_requests/<mr>/discussions/<id> -X PUT -f "resolved=true"`.

Re-fetch afterwards and confirm each posted thread shows resolved.

## Step 7: Summarize

One short summary: what was fixed, what was explained, what was deferred, and confirmation that nothing was committed, pushed, or posted beyond what I approved.
