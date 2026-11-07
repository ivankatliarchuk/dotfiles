<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Code Comments](#code-comments)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Code Comments

Default to writing no code comments. Only add a comment when it explains something the code itself cannot show: a hidden constraint, a non-obvious invariant, a workaround for a specific bug, or behavior that would surprise a careful reader. If removing the comment would not confuse a future reader, do not write it.

Never explain WHAT the code does (well-named identifiers already do that). Never reference the current task, fix, or callers (for example "used by X", "added for Y flow", "handles case from issue #123"); those belong in the commit message or PR description, not in the source.

Keep every comment to a single line. Never write multi-line comment blocks or multi-paragraph docstrings.

Before finalizing any code change, review each comment you wrote or kept against the "explains what code can't show" standard, and delete the ones that fail it. State in the final summary that this review was performed.
