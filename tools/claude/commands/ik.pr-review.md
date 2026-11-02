<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Step 1: Gather the change](#step-1-gather-the-change)
- [Step 2: PR summary](#step-2-pr-summary)
- [Step 3: Propose a split and gate before dispatch](#step-3-propose-a-split-and-gate-before-dispatch)
- [Step 4: Dispatch and consolidate](#step-4-dispatch-and-consolidate)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Review a pull or merge request (or the current branch) and prepare a PR summary, then have sub-agents perform a full review.

Input: $ARGUMENTS is a PR or MR number or URL. If empty, review the current branch against its base.

You are allowed to run read-only git plus the host's CLI (`gh` for github.com, `glab --hostname <host>` for anything else) without asking, because the operator explicitly invoked this command. Allowed commands: `git branch --show-current`, `git diff`, `git log`, `git merge-base`, `gh pr view/diff`, `glab mr view/diff`, and GET-only `gh api` / `glab api` calls. Never post, commit, or push anything.

## Step 1: Gather the change

- Detect the host first: parse `git config --get remote.origin.url`. If the host is `github.com`, use `gh`; otherwise use `glab --hostname <host>` (confirm with `glab auth status`). Terminology below uses "PR or MR" to cover both.
- For a PR or MR: read the title, description, source branch, and diff via the detected CLI.
- For the current branch: `git branch --show-current`, `git diff $(git merge-base HEAD origin/HEAD)..HEAD`, `git log $(git merge-base HEAD origin/HEAD)..HEAD --oneline`, and `git diff --cached $(git merge-base HEAD origin/HEAD)`.

## Step 2: PR summary

Output concisely:

**Branch:** <branch name>
**Suggested branch name:** <kebab-case name derived from the diff>
**Title:** <short imperative title, max 72 chars, starting with the story key, e.g. `SPES-XXXX: ...`>
**Why:** <bullets: motivation or problem being solved>
**What:** <bullets of key changes: features and intent, not files>

## Step 3: Propose a split and gate before dispatch

Divide the review into at most 5 batches so several sub-agents can work in parallel. Use 1 agent if the diff is tiny. You choose the split dimension based on the shape of this change, aiming for clean, least-overlapping batches:

- By file or file group: natural when files are independent.
- By concern or subsystem: for example scripts with their tests, generated or config files with the code that generates them, security-sensitive source on its own, docs and CI together.
- By review dimension: for example one agent each for correctness, security, and consistency, each looking across the whole diff. Good when the change is tightly coupled.
- By model cost: cheap sub-agents (Haiku) gather raw facts such as call sites, usages, and test coverage, then one stronger model reasons over the results and writes the findings.
- A mix of the above.

Show the proposed batches, the model for each, and what each will look at. Wait for my approval before dispatching anything.

## Step 4: Dispatch and consolidate

Run the approved sub-agents in parallel, read-only. Consolidate their findings into one list ordered by severity, each with file and line, the claim, and the evidence. Verify any technical claim that is checkable before reporting it as real.

Do not post comments, commit, or push. This is for review only.

<!-- Reconstructed from the command's one-line description and the "split and gate before dispatch" fragment in prompt history, not the original. -->
