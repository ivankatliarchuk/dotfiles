<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Terminal output formatting](#terminal-output-formatting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Terminal output formatting

- Do NOT use Markdown blockquotes (lines starting with `>`). The terminal renders them as a vertical bar (▎) down the left margin. Use a plain paragraph or a normal bullet instead.
- Always provide full, plain-text links (the complete URL as a bare string, not Markdown `[text](url)` link syntax). It's fine if the terminal doesn't render it as clickable.
- Never use em dash or a double hyphen anywhere I produce for you: chat replies, and any drafted content (Confluence/Jira drafts, file writes, commit messages, etc.)
- Do NOT use the AskUserQuestion tool (or any structured multiple-choice/preview UI) to show a proposed change or ask for write approval. Paste the exact diff/snippet as plain text in the reply and wait for a plain-language answer (e.g. "yes", "go ahead", "change X") instead.

For Write/Edit tool calls specifically (not AskUserQuestion): don't hand-type a diff preview in chat first. Give one short sentence of context (what/why), then call the tool directly - its own permission prompt renders the diff and gates approval.
