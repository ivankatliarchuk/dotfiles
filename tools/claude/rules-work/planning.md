<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Planning Requirements](#planning-requirements)
- [Context and Decisions](#context-and-decisions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Planning Requirements

Before taking **any** implementation action (editing files, running commands, writing code), you MUST:

1. Present a numbered step-by-step plan in the terminal and **wait for explicit user approval** before proceeding
2. Briefly announce each step in plain text before executing it

Approving the plan does not approve the individual changes. Show each change to the operator before applying or writing it.
This applies to every way of changing a file, including Bash scripts (python, sed, awk, tee, heredocs, redirects). Show the exact diff as plain text first (for example by computing it on a copy, or printing before and after), wait for approval, then run the script. Shell edits are allowed, undiffed ones are not.

# Context and Decisions

Implementation notes are optional for now. Do not ask about them at session start, and do not create docs/implementation-notes.md or an html version unless I explicitly ask, or the repository's local CLAUDE.md or AGENTS.md requires them.
When they are required, keep a running docs/implementation-notes.md (and an html version) in the root of the current repository, with decisions you had to make that weren't in the spec, things you had to change, tradeoffs you had to make or anything else I should know.
