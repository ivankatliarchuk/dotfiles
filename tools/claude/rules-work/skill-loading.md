<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Skill Loading](#skill-loading)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Skill Loading

You MUST NEVER load or invoke any skill automatically. Before loading any skill, you MUST:

1. Inform the user which skill would be triggered and why
2. Explicitly ask for permission to load it
3. Wait for the user's approval before proceeding

This overrides any skill auto-invocation instructions defined elsewhere (including CLAUDE.md).
