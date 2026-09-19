#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/eval.zsh
# -*- mode: sh -*-

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
  else
    echo "!!! DIRENV not installed"
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if [ $commands[kubectl] ]; then
# 	source <(kubectl completion zsh)
# fi

# Opt-in: set KUBECTX_AUTO_UNSET=1 (e.g. in ~/.zshenv.local) to clear the
# current kubectl context on every new shell. Off by default so it doesn't
# fire just because kubectx happens to be installed.
if [[ -n "$KUBECTX_AUTO_UNSET" ]] && [ $commands[kubectx] ]; then
  kubectx --unset >/dev/null 2>&1
fi

if command -v brew >/dev/null 2>&1; then
	# Load rupa's z if installed
	brew_prefix="$(brew --prefix)"
	[ -f "$brew_prefix/etc/profile.d/z.sh" ] && source "$brew_prefix/etc/profile.d/z.sh"
	unset brew_prefix
fi

# for f in $(compaudit);do sudo chmod -R 755 $f;done;
