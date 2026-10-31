<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Step 1: Read the rules first](#step-1-read-the-rules-first)
- [Step 2: Find candidates](#step-2-find-candidates)
- [Step 3: Prepare each chosen diagram](#step-3-prepare-each-chosen-diagram)
- [Step 4: Show before writing](#step-4-show-before-writing)
- [Step 5: Write](#step-5-write)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Find mermaid/PlantUML diagrams Claude produced in a session and turn them into diagrams/ entries.

Input: $ARGUMENTS is optional: a diagram description to narrow to, or a path to the diagram source. If empty, scan the whole current session.

Vault: `${CLAUDE_VAULT_DIR:-$HOME/knowledgebase}`. Entries live in `diagrams/<slug>.md` and are listed in `diagrams/index.md`.

## Step 1: Read the rules first

Read `diagrams/blueprint.md` in the vault and follow it exactly. Also read the vault root `CLAUDE.md` for the Frontmatter Convention.

## Step 2: Find candidates

Scan this session for mermaid and PlantUML code blocks. Keep only the latest approved version of each diagram, not intermediate revisions shown in chat. Skip a diagram that already lives elsewhere in the vault and reference it in `index.md` instead of copying it. If a diagram exists only as a rendered image, follow the blueprint's "Rendered images" section.

List the candidates as a numbered list with a one-line description each, and ask which to index.

## Step 3: Prepare each chosen diagram

For every chosen diagram check the blueprint's content rules:
- A `title` at the top and at least one closing Note with the key takeaway.
- In a `sequenceDiagram`, any `box` has an explicit color (`box rgb(230,230,250) <label>`), never `transparent` or unspecified, and only one box-group set per diagram. Split before/after comparisons into two diagrams.
- No secrets, tokens, or internal hostnames and IPs in node labels.

Validate the syntax for real with `npx -y @mermaid-js/mermaid-cli -i /tmp/x.mmd -o /tmp/x.svg`, and fix and re-validate if it fails. Clean validation does not guarantee correct box rendering, so say so.

## Step 4: Show before writing

For each diagram show together in one message: new filename (`<slug>.md`, kebab-case, no version suffix), title, summary, the 5 tags spelled out, and the actual diagram code block. Wait for explicit approval before writing.

## Step 5: Write

On approval, write `diagrams/<slug>.md` using the blueprint template, and add the line `- [slug.md](slug.md) - one line: what it depicts` to `diagrams/index.md`. Do not commit or push the knowledgebase.

<!-- Reconstructed from diagrams/blueprint.md and the command's one-line description, not the original. -->
