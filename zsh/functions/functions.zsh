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
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

load-tofuswitch() {
  # https://tfswitch.warrensbox.com/usage/ci-cd/
  local tfswitchrc_path=".tfswitchrc"
  local tf_path=".opentofu-version"

  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  elif [ -f "$tf_path" ]; then
    local tofu_version=$(tofu -version | head -n 1 | awk '{print $2}')
    local desired_version=$(cat "$tf_path")
    export TOFU_VERSION=$tofu_version
    if [[ "$tofu_version" =~ "$desired_version" ]]; then
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

# Automatically switch golang version via mise when a directory has a `go.mod` file
load-go-version() {
  if exists mise; then
    if [ -f go.mod ]; then
      local GO_LOCAL_VERSION
      GO_LOCAL_VERSION=$(go list -f '{{.GoVersion}}' -m 2>/dev/null)
      if [ -n "$GO_LOCAL_VERSION" ]; then
        local GO_CURRENT_VERSION
        GO_CURRENT_VERSION=$(go version | { read _ _ v _; echo ${v#go}; })
        if [ "$GO_CURRENT_VERSION" != "$GO_LOCAL_VERSION" ]; then
          echo "mise: switching go ${GO_CURRENT_VERSION} -> ${GO_LOCAL_VERSION}"
          mise install -q "go@${GO_LOCAL_VERSION}" >/dev/null 2>&1
          mise shell "go@${GO_LOCAL_VERSION}" >/dev/null 2>&1
        fi
      fi
    fi
  fi
}

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

# Run all directory-based tool-version switchers on cd, and once on shell load
load-dir-hooks() {
  load-tofuswitch
  load-tgswitch
  load-go-version
  load-pyenv
}
# Declared here rather than relying on eval.zsh's load order (this file's
# name used to just happen to sort after eval.zsh's autoload).
autoload -U add-zsh-hook
add-zsh-hook chpwd load-dir-hooks
load-dir-hooks

zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!

# Cache completion if nothing changed - faster startup time
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r "$zcompdump" 2>/dev/null || stat -f '%Sm' -t '%j' "$zcompdump" 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
