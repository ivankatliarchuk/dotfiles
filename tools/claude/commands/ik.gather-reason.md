<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [The pattern](#the-pattern)
- [Steps](#steps)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Decompose any task into the cheap-gather, expensive-reason agent pattern and output the resulting prompt.

Input: $ARGUMENTS is the task to decompose, for example "Investigate why checkout latency spiked yesterday and write an incident summary". If it is empty, ask for the task.

Reference note: `${CLAUDE_VAULT_DIR:-$HOME/knowledgebase}/ai-tools/prompts/cheap-gather-expensive-reason.md`. Read it first.

## The pattern

Split the task by cost, not by subject. Cheap, fast subagents (Haiku) only gather raw facts from data sources in parallel, with no analysis. One expensive model then correlates everything and writes the final result. Gathering does not need reasoning, only many cheap parallel runs. Reasoning and writing need the strongest model, once, over data already collected.

## Steps

1. Identify the distinct data sources the task needs (for example Grafana or Loki, Splunk, deploy and change history, Slack, Jira, git, Confluence).
2. For each source, write one gather instruction. Each must say: what to query, the time window or scope, and "return raw facts only (numbers, timestamps, log lines, message text), no conclusions".
3. Write the reasoning instruction that receives the combined raw output and tells the main model what to correlate, what to decide, and the exact output to produce (for example timeline, root cause, follow-ups).
4. Output one ready-to-paste prompt in this shape:

Spawn cheap/fast subagents (haiku) in parallel, one per data source, to gather raw facts only, no analysis:

1. agent: <source and query>. Return <raw fields> only.
2. agent: <source and query>. Return <raw fields> only.

Once all subagents finish, pass their combined raw output to the main model:

"<reasoning instruction>"

Subagents are for collection only. The main model does correlation, judgment, and writing.

5. Add the caveat in one line: keep the model swap at the subagent boundary, because switching the main session model mid-session re-ingests context and loses prompt caching.

Only output the prompt. Do not run the subagents unless I ask.
