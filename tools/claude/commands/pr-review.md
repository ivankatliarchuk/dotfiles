Review the current branch and prepare a PR summary:

1. Run `git branch --show-current` to get the branch name
2. Run `git diff $(git merge-base HEAD origin/HEAD)..HEAD` for the full diff vs base branch
3. Run `git log $(git merge-base HEAD origin/HEAD)..HEAD --oneline` for commit list
4. Run `git diff --cached $(git merge-base HEAD origin/HEAD)`
5. Output the following, concisely:

**Branch:** <current-branch-name>
**Suggested branch name:** <kebab-case name derived from the diff, e.g. `feat/add-login-timeout` or `fix/null-pointer-on-checkout`>
**Title:** <short imperative title, max 72 chars. should start with story e.g `SPES-XXXX: ....`>
**Why:** <bullet points — motivation or problem being solved>
**What:** <bullet points of key changes. Must be WHAT aka features and intent, not files>

Do not post, commit, or push anything. This is for review only.
