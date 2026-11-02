<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Mermaid Diagrams](#mermaid-diagrams)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Mermaid Diagrams

- In `sequenceDiagram` `box ... end` blocks used to group participants, always give the box an explicit color: `box rgb(230,230,250) <label>`. Never leave the color unspecified and never use `transparent` - my renderer fills unspecified/transparent boxes as solid black hachure.
- Never put more than one separate `box ... end` grouping scenario in a single `sequenceDiagram` (e.g. a "current state" set of boxes plus a "target state" set of boxes joined by a `Note` in between) - this renders as black boxes even when every box has an explicit color. Use one box-group set per diagram; if a before/after comparison is needed, make two separate diagrams instead.
- Validate syntax with `npx -y @mermaid-js/mermaid-cli` first, but note clean CLI validation does not guarantee correct box fill rendering.
