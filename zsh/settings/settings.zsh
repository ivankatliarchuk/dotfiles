#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/settings/settings.zsh

# Initialize completion
autoload -U colors && colors
autoload -Uz compinit && compinit -i
zstyle ':completion:*' menu select=4
zmodload zsh/complist

rehash
unsetopt nomatch

# Enable interactive comments (# on the command line)
setopt interactivecomments

# Time to wait for additional characters in a sequence
KEYTIMEOUT=1 # corresponds to 10ms
