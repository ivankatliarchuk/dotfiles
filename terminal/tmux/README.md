<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Tmux Configuration Files](#tmux-configuration-files)
  - [TmuxP configs](#tmuxp-configs)
  - [How to](#how-to)
  - [Config examples](#config-examples)
  - [How to get layour string](#how-to-get-layour-string)
  - [Read configs](#read-configs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Tmux Configuration Files

- [TmuxP](https://github.com/tmux-python/tmuxp)
- [Docs](http://tmuxp.readthedocs.io/en/latest/)

## TmuxP configs

- [Config: example](http://tmuxp.git-pull.com/en/latest/examples.html#short-hand-inline)
- [Config: example](https://github.com/tony/tmuxp-config)

## How to

```bash

tmuxp load <config-file>
tmux

```

## Config examples

- [Tmux 11k](https://github.com/gpakosz/.tmux)
- [MacOSX-pasteboard 2k](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard)
- [Tmux Config 1k](https://github.com/samoshkin/tmux-config)

## How to get layour string

```tmux

$ tmux display-message -p "#{window_layout}"
> 4591,157x35,0,0{116x35,0,0,1,40x35,117,0[40x14,117,0,2,40x20,117,15,3]}
```

## Read configs

```bash
defaults read com.googlecode.iterm2.plist
```
