#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/functions.zsh
# -*- mode: sh -*-
# shellcheck source=/dev/null
# shellcheck source=/dev/null
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
    if [[ -a "$nvmrc_path" ]]; then
    local nvmrc_node_version=$(cat "${nvmrc_path}")
      if [ "$nvmrc_node_version" = "N/A" ]; then
        n latest
      elif [ "$nvmrc_node_version" != "$current_node_version" ]; then
        n $nvmrc_node_version
      fi
    fi
  fi
}
# Run load-nvmrc on initial shell load
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!
