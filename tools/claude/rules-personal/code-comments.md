<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Code Comments](#code-comments)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Code Comments

- Default to no code comments. Only add one when it explains something the code itself cannot show: a hidden constraint, a non-obvious invariant, a workaround for a specific bug, or surprising behavior.
- Never explain WHAT the code does (names already do that).
- Never reference the current task, fix, or callers (e.g. "used by X", "added for Y flow", "handles case from issue #123"); those belong in the commit message or PR description.
- Keep every comment to a single line. No multi-line comment blocks or multi-paragraph docstrings.
- Before finalizing a code change, review each comment against the "explains what code can't show" standard and delete the ones that fail it. State in the final summary that this review was performed.
