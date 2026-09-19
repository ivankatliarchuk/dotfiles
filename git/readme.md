<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Git Readme](#git-readme)
  - [Stash](#stash)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Git Readme

Remove submodule

```sh
git submodule deinit -f vendor/<name>
rm -rf .git/modules/vendor/<name>
git rm -f vendor/<name>
```

Rebase

```
git -c sequence.editor="code --wait --reuse-window" rebase -i HEAD~ # add `.` to rebase the last commit or number of commits
```

## Stash

```sh
Summary (files changed):
git stash show stash@{1}

Full diff:
git stash show -p stash@{1}

List all stashes:
git stash list
```
