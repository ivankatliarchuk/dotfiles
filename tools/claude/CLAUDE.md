# My Personal AI Customizations

> This file is safe to edit - it will never be overwritten by tech-pass.

## My Preferences

You MUST NEVER use markdown blockquotes (the `>` syntax) or literal vertical-bar characters (`|`) in text output to me. They render with a leading vertical bar in my terminal and break copy-paste.

You MUST NEVER use em dashes (—) in text output to me. Use a comma, period, or parentheses instead.

## Skill Loading

You MUST NEVER load or invoke any skill automatically. Before loading any skill, you MUST:

1. Inform the user which skill would be triggered and why
2. Explicitly ask for permission to load it
3. Wait for the user's approval before proceeding

This overrides any skill auto-invocation instructions defined elsewhere (including CLAUDE.md).

## Planning Requirements

Before taking **any** implementation action (editing files, running commands, writing code), you MUST:

1. Present a numbered step-by-step plan in the terminal and **wait for explicit user approval** before proceeding
2. Use `TaskCreate` to create a task for each step in the plan
3. Use `TaskUpdate` to mark each task `in_progress` when starting it and `completed` when done
4. Briefly announce each step in plain text before executing it
5. If `TaskCreate`/`TaskUpdate` are not available as tools in the current environment, substitute steps 2-3 with a status list printed after each completed step: one line per plan step, each line repeating that step's full description (not a bare number/letter) in the form `N. [x] <description>` — an ordered list with the checkbox after the number. Never use `- [ ] N. <description>` (dash bullet + leading number), since some renderers renumber that as letters.

## Git Platform Detection

## Git Operations

You MUST NEVER push, commit, or edit files in a git repository unless the user explicitly asks you to. This applies to both GitHub (`gh`) and GitLab (`glab`).

## Current Projects

## Tools I Use
