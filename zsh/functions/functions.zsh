#!/bin/zsh
# -*- mode: sh -*-

#
# Helper functions that don't belong elsewhere.
#

prompt_dir() {
	# prompt_segment blue black " `basename ${PWD/#$HOME/'%2~'}` "
	prompt_segment blue $CURRENT_FG '%2~'
}

function get_cluster_short() {
	echo "$1" | cut -d / -f2 | cut -d . -f1
}

function get_namespace_upper() {
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

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!
