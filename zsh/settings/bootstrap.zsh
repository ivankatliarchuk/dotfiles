# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/zsh/settings/bootstrap.zsh
# Clears the terminal on new tabs (interactive login shells) only, not in nested shells or scripts.
[[ -o login && -o interactive ]] && printf '\33c\e[3J'

# Ensure PATH-like arrays stay deduplicated for the life of this shell,
# regardless of whether zprofile ran (it only sources for login shells).
typeset -gU cdpath fpath mailpath path

# Source a tool's init script from a cache, regenerated only when the resolved binary changes (upgrade or move).
_cached_eval() {
  local name="$1"; shift
  local bin="${commands[$1]:A}"
  [[ -n "$bin" ]] || return 1
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${name}.zsh" header="# cached from ${bin}" first_line='' output=''
  [[ -r "$cache" ]] && read -r first_line < "$cache"
  if [[ "$first_line" != "$header" ]]; then
    output="$("$@" 2>/dev/null)" || return 1
    mkdir -p "${cache:h}"
    print -r -- "${header}"$'\n'"${output}" >! "$cache"
  fi
  source "$cache"
}

if [[ -n "$DEBUG" ]]; then
  typeset -F SECONDS; setopt prompt_subst; PS4='$SECONDS+%N:%i> '
  set -x
fi

if [[ "$CPUTYPE" == 'arm64' ]]; then
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

_cached_eval starship starship init zsh --print-full-init || echo "!!! STARSHIP not installed"

# not required so often
# if [ -f "/usr/local/opt/asdf/libexec/asdf.sh" ]; then
#   . /usr/local/opt/asdf/libexec/asdf.sh
# fi

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
export PATH="$HOME/.local/bin:$PATH"

# Not cached: `mise activate` output embeds the current PATH, so a cached copy would go stale.
command -v mise >/dev/null && eval "$(mise activate zsh)"
