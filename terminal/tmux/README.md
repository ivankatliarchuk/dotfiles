<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Blogs and Docs](#blogs-and-docs)
  - [TmuxP configs](#tmuxp-configs)
  - [How to](#how-to)
  - [Config examples](#config-examples)
  - [Tools](#tools)
  - [How to get layour string](#how-to-get-layour-string)
  - [Read configs](#read-configs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Blogs and Docs

- [Wikipedia](https://github.com/tmux/tmux/wiki)
- [Tmux easy way](https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
- [How To Tmux](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/)
- [Useful guides](https://dev.to/iggredible/useful-tmux-configuration-examples-k3g)

## TmuxP configs

- [Config: example](http://tmuxp.git-pull.com/en/latest/examples.html#short-hand-inline)
- [Config: example](https://github.com/tony/tmuxp-config)
- [Cheat Sheet](https://tmuxcheatsheet.com/)

## How to

```bash

tmuxp load <config-file>
tmux
tmux show -g
```

## Config examples

- [Tmux 11k](https://github.com/gpakosz/.tmux)
- [MacOSX-pasteboard 2k](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard)
- [Tmux Config 1k](https://github.com/samoshkin/tmux-config)
- [TmuxP](https://github.com/tmux-python/tmuxp)
- [Docs](http://tmuxp.readthedocs.io/en/latest/)
- [Layouts](https://tmuxp.git-pull.com/configuration/examples.html)

## Tools

- [Tmuxinator](https://github.com/tmuxinator/tmuxinator)

## How to get layour string

```bash
tmux list-windows
> 0: zsh* (2 panes) [233x51] [layout d467,233x51,0,0[233x24,0,0,1,233x26,0,25,2]] @1 (active)
> 1: zsh (2 panes) [800x600] [layout 4de2,800x600,0,0{399x600,0,0,3,400x600,400,0,4}] @2
> 2: zsh- (2 panes) [800x600] [layout a464,800x600,0,0[800x299,0,0,5,800x300,0,300,6]] @3
> 3: zsh (3 panes) [800x600] [layout 3336,800x600,0,0[800x199,0,0,7,800x199,0,200,8,800x200,0,400,9]] @4
tmux display-message -p "#{window_layout}"
> 4591,157x35,0,0{116x35,0,0,1,40x35,117,0[40x14,117,0,2,40x20,117,15,3]}
```

## Read configs

```bash
defaults read com.googlecode.iterm2.plist
```
