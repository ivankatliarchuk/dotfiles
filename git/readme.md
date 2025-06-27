<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Git Readme](#git-readme)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Git Readme

Remove submodule

```sh
git submodule deinit -f vendor/bash-it
rm -rf .git/modules/vendor/bash-it
git rm -f vendor/bash-it
```

Rebase

```
git -c sequence.editor="code --wait --reuse-window" rebase -i HEAD~ # add `.` to rebase the last commit or number of commits
```
