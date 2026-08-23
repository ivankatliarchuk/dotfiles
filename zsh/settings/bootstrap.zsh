# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/settings/bootstrap.zsh
printf '\33c\e[3J' # hides last logic command

# Ensure PATH-like arrays stay deduplicated for the life of this shell,
# regardless of whether zprofile ran (it only sources for login shells).
typeset -gU cdpath fpath mailpath path

if [[ -n "$DEBUG" ]]; then
  typeset -F SECONDS; setopt prompt_subst; PS4='$SECONDS+%N:%i> '
  set -x
fi

if [[ $(uname -m) == 'arm64' ]]; then
  # make sure to link required things to path
  # find . -type l -ls
  # ln -s /opt/homebrew/bin/pinentry-mac /usr/local/bin/
  # ls -s /opt/homebrew/bin/gpg /usr/local/bin/
  # remove rm /usr/local/bin/bin
  # on new mac run 'gpg-restart' to make directory safe
  export PATH="/opt/homebrew/bin:$PATH"
  #  Homebrew puts admin/daemon-style tools (things traditionally requiring root, like network daemons) in sbin.
  export PATH="/opt/homebrew/sbin:$PATH"
fi

umask 077
# Created by dotfiles
[[ "$TERM" == "screen" ]] && export TERM=screen-256color

# load custom executable functions
for func in ~/.zsh/functions/*; do
  if [[ -r "$func" ]] && [[ -f "$func" ]]; then
    source "$func"
  fi
done
unset func

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
if command -v utils > /dev/null; then
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

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin:$(go env GOPATH)/bin"
if command -v go >/dev/null 2>&1; then
    export PATH="$PATH:$(go env GOPATH)/bin"
  else
    echo "!!! GO not installed"
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
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"
[[ -s "${HOME}/.krew/bin" ]] && export PATH="${HOME}/.krew/bin:${PATH}"
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

command -v mise >/dev/null && eval "$(mise activate zsh)"

clear # clear the terminal in initialization from any initialization prints
