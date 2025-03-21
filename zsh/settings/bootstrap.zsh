# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/zshrc
umask 077
[[ -n "${DEBUG:-}" ]] && set -x
# Created by dotfiles
[[ "$TERM" == "screen" ]] && export TERM=screen-256color

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

for cmd in ~/.config/.cmds/*; do
	if [[ -r "$cmd" ]] && [[ -f "$cmd" ]]; then
		source "$cmd"
	fi
done
unset cmd

[[ -f ~/.functions ]] && source ~/.functions     # Global Functions
[[ -f ~/local/.zshrc ]] && source ~/local/.zshrc # Local config
[[ -f ~/.exports ]] && source ~/.exports         # Exports
# aliases
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.tmuxp/aliases ]] && source ~/.tmuxp/aliases
[[ -f ${HOME}/.zsh/settings/settings.zsh ]] && source ${HOME}/.zsh/settings/settings.zsh # Settings

for al in ~/.config/aliases/*; do
	if [[ -r "$al" ]] && [[ -f "$al" ]]; then
		# shellcheck source=/dev/null
		source "$al"
	fi
done
unset al

# run only on new shell creation
if which utils > /dev/null; then
  source utils
fi

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

if [[ -n "$TMUX" ]];then
  export CURRENTPWD=$PWD
  if [[ -n "$VAGRANT" ]];then
      export STARSHIP_CONFIG=~/.config/starship/vagrant.toml
    else
      export STARSHIP_CONFIG=~/.config/starship/tmux.toml
  fi
else
  if [[ -n "$VAGRANT" ]];then
      export STARSHIP_CONFIG=~/.config/starship/vagrant.toml
    else
      export STARSHIP_CONFIG=~/.config/starship/main.toml
  fi
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  else
    echo "!!! STARSHIP not installed"
fi

# not required so often
# if [ -f "/usr/local/opt/asdf/libexec/asdf.sh" ]; then
#   . /usr/local/opt/asdf/libexec/asdf.sh
# fi

# https://github.com/moovweb/gvm/issues/463
unalias cd
[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin:$(go env GOPATH)/bin"
if command -v go >/dev/null 2>&1; then
    export PATH="$PATH:$(go env GOPATH)/bin"
  else
    echo "!!! GVM and GO not installed"
fi
# curl is keg-only, which means it was not symlinked into /usr/local
[[ -s "/usr/local/opt/curl" ]] && export PATH="/usr/local/opt/curl/bin:$PATH"

# Load Linux grep
if [ -f "/usr/local/opt/grep/libexec/gnubin" ]; then
  export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
fi

if [ -f "/usr/local/bin/aws" ]; then
  alias aws="/usr/local/bin/aws"
fi

# pnpm
export PNPM_HOME="/Users/$(whoami)/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export GOPATH=$HOME
export PATH="$GOPATH/bin:$PATH"
[[ -s "${HOME}/.krew/bin" ]] && export PATH="${PATH}:${HOME}/.krew/bin"
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
