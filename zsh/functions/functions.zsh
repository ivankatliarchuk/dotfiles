#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/functions.zsh
# -*- mode: sh -*-
# shellcheck source=/dev/null
#
# Helper functions that don't belong elsewhere.
#

exists() {
  command -v "$1" >/dev/null 2>&1
}

prompt_dir() {
  prompt_segment blue $CURRENT_FG '%2~'
}

get_cluster_short() {
  echo "$1" | cut -d / -f2 | cut -d . -f1
}

get_namespace_upper() {
    echo "$1" | tr '[:lower:]' '[:lower:]'
}

load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"

  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  fi
}

load-tgswitch() {
  local tgswitchrc_path=".tgswitchrc"

  if [ -f "$tgswitchrc_path" ]; then
    tgswitch
  fi
}

add-zsh-hook chpwd load-tfswitch
load-tfswitch

add-zsh-hook chpwd load-tgswitch
load-tgswitch

# Automatically switch and load node versions when a directory has a `.nvmrc` file
load-nvmrc() {
  if exists nvm; then
    if [ -f .nvmrc  ]; then
      if [[ "$(node -v)" != "$(cat .nvmrc)" ]]; then
        nvm use $(cat .nvmrc) >/dev/null 2>&1
        echo "Switched node to version \"$(node -v)\""
      fi
      if [ $? -eq 1 ]
      then
        echo "Im here 1"
        nvm install $(cat .nvmrc)
        nvm use $(cat .nvmrc) >/dev/null 2>&1
        echo "Switched node to version \"$(node -v)\""
      fi
    fi
  fi
}
# Run load-nvmrc on initial shell load
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Automatically switch and load golang versions when a directory has an `.gvmrc` file
load-gvmrc() {
  if exists gvm; then
    if [ -f .gvmrc  ]; then
        if ! go version | grep "$(cat .gvmrc)" >/dev/null 2>&1; then
          gvm use $(cat .gvmrc) >/dev/null 2>&1
          echo "Switched golang to version \"$(go version)\""
        fi
      if [ $? -eq 1 ]
      then
        gvm install $(cat .gvmrc)
        gvm use $(cat .gvmrc) >/dev/null 2>&1
        echo "Switched golang to version \"$(go version)\""
      fi
    fi
  fi
}
add-zsh-hook chpwd load-gvmrc
load-gvmrc

# Automatically switch and load python versions when a directory has an `.python-version` or `.pyrc` file
load-pyenv() {
  if exists pyenv; then
    if [ -f .python-version  ] || [ -f .pyrc  ] || [ -f Pipfile  ]; then
        local version=''
        if [ -f .python-version  ];then
          version=$(cat .python-version)
        fi
        if [ -f .pyrc  ];then
          version=$(cat .pyrc)
        fi
        if [ -f Pipfile  ];then
          information "Found pipfile. \$pipenv install --skip-lock"
        fi
        if [[ "$version" != "$PYENV_VERSION" ]]; then
          if ! pyenv versions | grep $version >/dev/null 2>&1; then
            pyenv install $version --skip-existing
            pyenv rehash # if version do not match
          fi
        fi
        PYENV_VERSION=$version
    else
      PYENV_VERSION=$PYENV_GLOBAL_VERSION
    fi
  fi
}
add-zsh-hook chpwd load-pyenv
load-pyenv

if [[ -n "$TMUX" ]] ;then
: # do nothhing
else
# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!
fi

# Cache completion if nothing changed - faster startup time
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# Enhanced form of menu completion called `menu selection'
zmodload -i zsh/complist
