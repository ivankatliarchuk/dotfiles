<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Planning Requirements](#planning-requirements)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Planning Requirements

Before taking **any** implementation action (editing files, running commands, writing code), you MUST:

1. Present a numbered step-by-step plan in the terminal and **wait for explicit user approval** before proceeding
2. Use `TaskCreate` to create a task for each step in the plan
3. Use `TaskUpdate` to mark each task `in_progress` when starting it and `completed` when done
4. Briefly announce each step in plain text before executing it
5. If `TaskCreate`/`TaskUpdate` are not available as tools in the current environment, substitute steps 2-3 with a status list printed after each completed step: one line per plan step, each line repeating that step's full description (not a bare number/letter) in the form `N. [x] <description>` — an ordered list with the checkbox after the number. Never use `- [ ] N. <description>` (dash bullet + leading number), since some renderers renumber that as letters.
