#!/bin/zsh
# -*- mode: sh -*-

#
# Key remappings. Mostly related to OS X.
#
# key mappings
bindkey "^[^[[C"  forward-word              # alt + right
bindkey "^[^[[D"  backward-word             # alt + left
bindkey "^[^[[A"  _history-complete-older   # alt + up
bindkey "^[^[[B"  _history-complete-newer   # alt + down
