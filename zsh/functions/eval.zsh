#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/eval.zsh
# -*- mode: sh -*-

eval "$(direnv hook zsh)"

# Load zprezto if it's installed
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

if [ -n "$ZSH_VERSION" ]; then
  autoload -U bashcompinit
  bashcompinit
fi

# Uncomment when vault is in use
# eval "$(aws-vault --completion-script-zsh)"
# if [[ -d "$PYENV_ROOT" ]]; then
#   # TODO: validate if not set
#   export PATH="$(pyenv root)/shims:$PATH"
# fi
# eval "$(hub alias -s)"

source <(navi widget zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ $commands[kubectl] ]; then
	source <(kubectl completion zsh)
fi

if [ $commands[kubectx] ]; then
  kubectx --unset >/dev/null 2>&1
fi

if command -v brew >/dev/null 2>&1; then
	# Load rupa's z if installed
	[ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
  autoload -Uz compinit
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

for f in $(compaudit);do sudo chmod -R 755 $f;done;
