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
  # https://tfswitch.warrensbox.com/usage/ci-cd/
  local tfswitchrc_path=".tfswitchrc"
  local tf_path=".opentofu-version"

  if [ -f "$tfswitchrc_path" ]; then
    TF_PRODUCT=opentofu
    tfswitch
  elif [ -f "$tf_path" ]; then
    TF_PRODUCT=opentofu
    local tofu_version=$(tofu -version | head -n 1 | awk '{print $2}')
    local desired_version=$(cat "$tf_path")
    export TOFU_VERSION=$tofu_version
    if [[ "$desired_version" =~ "$tofu_version" ]]; then
      export TOFU_VERSION=$desired_version
    else
      export TOFU_VERSION=$desired_version
      tfswitch --product opentofu $desired_version
    fi
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

# https://github.com/nvm-sh/nvm
load-nvmrc() {
  if exists nvm && [[ "$PWD" != "$HOME" ]]; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"
    if [ -f .nvmrc  ]; then

      if [[ -n "$nvmrc_path" ]]; then
        if [[ "${$(nvm current)#"v"}" != "$(cat .nvmrc)" ]]; then
          local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

          if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
          elif [ "$nvmrc_node_version" != "$node_version" ]; then
            nvm use
          fi
        fi
      elif [ "$node_version" != "$(nvm version default)" ]; then
        nvm use default
      fi
    fi
  fi
}
# Run load-nvmrc on initial shell load
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Automatically switch and load golang versions when a directory has an `.gvmrc` or `go.mod` files
load-go-version() {
  if exists gvm; then
    if [ -f .gvmrc  ] || [ -f go.mod  ]; then
        local GO_VERSION=$(go version | { read _ _ v _; echo ${v#go}; })
        if [ -f .gvmrc  ]; then
            local GO_GVMRC_VERSION=$(cat .gvmrc)
            if ! go version | grep "$GO_GVMRC_VERSION" >/dev/null 2>&1; then
              gvm use $GO_GVMRC_VERSION >/dev/null 2>&1
            fi
          if [ $? -eq 1 ]
          then
            gvm install $GO_GVMRC_VERSION
            gvm use $GO_GVMRC_VERSION >/dev/null 2>&1
          fi
        fi
        if [ -f go.mod  ]; then
          local GO_LOCAL_VERSION=$(go list -f {{.GoVersion}} -m)
          if [[ "$GO_VERSION" == "$GO_LOCAL_VERSION" ]]; then
              # echo "version match"
            else
              gvm use ${GO_LOCAL_VERSION} 2>&1
          fi
          if [ $? -eq 1 ]
          then
            gvm install go${GO_LOCAL_VERSION}
            gvm use ${GO_LOCAL_VERSION} 2>&1
          fi
        fi
      fi
  fi
}
add-zsh-hook chpwd load-go-version
load-go-version

# Automatically switch and load python versions when a directory has an `.python-version` or `.pyrc` file
load-pyenv() {
  if exists pyenv; then
    if [ -f .python-version  ] || [ -f .pyrc  ]; then
        local version=''
        if [ -f .python-version  ];then
          version=$(cat .python-version)
        fi
        if [ -f .pyrc  ];then
          version=$(cat .pyrc)
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
