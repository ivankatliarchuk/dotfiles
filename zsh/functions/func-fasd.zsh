#!/bin/env zsh
# -*- mode: sh -*-
# https://github.com/clvv/fasd
#
# fasd settings.
#
# Author:
#   Ivan K. <cloudkats@gmail.com>
#

# Initialize fasd if installed
if [[ -x $(which fasd) ]]; then
  fasd_cache="$HOME/.fasd-init-zsh"
  if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
  fi
  source "$fasd_cache"
  unset fasd_cache
fi
