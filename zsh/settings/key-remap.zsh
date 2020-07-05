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

# Define how zsh handles escape sequences produced by terminal emulator
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
