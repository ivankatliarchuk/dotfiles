<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Rules for the hand-off](#rules-for-the-hand-off)
- [Steps](#steps)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Spawn a sub-agent to perform a full cold review of a pull or merge request (or the current branch) with no context from this session.

Input: $ARGUMENTS is a PR or MR number or URL. If empty, review the current branch against its base.

You are allowed to run read-only git plus the host's CLI (`gh` for github.com, `glab --hostname <host>` otherwise) without asking, because the operator explicitly invoked this command. Never post, commit, or push anything.

## Rules for the hand-off

The point of this command is an unbiased second opinion. The sub-agent must start cold:

- Pass only the change reference (PR or MR number or URL, or the branch name and repo path) and the review instructions below.
- Do not pass this session's conversation, your own opinions, prior findings, the reasons the change was made, or any hints about what is right or wrong.
- Do not summarize or pre-read the diff for it. The sub-agent fetches the diff itself.

## Steps

1. Resolve the target: PR or MR number or URL, or the current branch. Detect the host from `git config --get remote.origin.url` and pick `gh` or `glab --hostname <host>` accordingly. State which one you are using.
2. Spawn one sub-agent with this brief and nothing else about the session:

"Perform a full review of <change reference>. Read the title, description, and complete diff yourself, and read surrounding code where needed. Report findings ordered by severity (blocker, question, suggestion), each with file and line, the claim, and the evidence. Verify technical claims by grepping the code or running a scratch test before reporting them. Read-only: do not post comments, commit, or push."

3. Return the sub-agent's findings to me as written. Do not soften, filter, or add your own findings. If you disagree with one, say so in a separate note after the findings.

<!-- Reconstructed from the command's one-line description and a prompt asking for "a sub agent perform a full review with no context", not the original. -->
