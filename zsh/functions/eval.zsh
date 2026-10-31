#!/bin/env zsh
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/functions/eval.zsh
# -*- mode: sh -*-

_cached_eval direnv direnv hook zsh || echo "!!! DIRENV not installed"

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

# Load rupa's z if installed, checking known Homebrew prefixes instead of spawning `brew --prefix`
for brew_prefix in "${HOMEBREW_PREFIX:-/opt/homebrew}" /usr/local; do
	if [[ -f "$brew_prefix/etc/profile.d/z.sh" ]]; then
		source "$brew_prefix/etc/profile.d/z.sh"
		break
	fi
done
unset brew_prefix

# for f in $(compaudit);do sudo chmod -R 755 $f;done;
