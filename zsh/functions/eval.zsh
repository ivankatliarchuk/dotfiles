#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/eval.zsh
# -*- mode: sh -*-

eval "$(direnv hook zsh)"
eval "$(aws-vault --completion-script-zsh)"
source <(navi widget zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ $commands[kubectl] ]; then
	source <(kubectl completion zsh)
fi

if [ $commands[nvm] ]; then
	export NVM_DIR=~/.nvm
	source $(brew --prefix nvm)/nvm.sh
fi

if [ -f $HOME/.nvm ] ;then
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

if command -v brew >/dev/null 2>&1; then
	# Load rupa's z if installed
	[ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
  autoload -Uz compinit
  compinit
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

#------------------
# Zsh hooks
#------------------
autoload -U add-zsh-hook

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"
# Load Bash It
if [ -f "$BASH_IT"/bash_it.sh ]; then
    source "$BASH_IT"/bash_it.sh
fi
