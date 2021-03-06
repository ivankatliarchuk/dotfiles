#!/bin/bash
# shellcheck disable=SC2155
set -e

: "${INSTALL_BREW:=false}"
: "${HOMEBREW_BUNDLE_NO_LOCK:=true}"

[[ -n "${DEBUG:-}" ]] && set -x
# shellcheck source=/dev/null
[[ -f "scripts/utils" ]] && source scripts/utils

show_help() {
cat << EOF
Usage: $(basename "$0") :do:
    manage better brew
    brew install dependencies from files
    brew update & upgrade
    brew autoremove & cleanup
EOF
}

brew_install() {
  local brewexec=$(which brew)
  declare -a files=(
    "Brewfile"
    "Brewfile.secure"
    "Brewfile.networking"
    "Brewfile.git"
    "Brewfile.aws"
    "Brewfile.development"
    "Brewfile.k8s"
    "Brewfile.fonts"
  )
  # brew bundle --file=brew/Brewfile.vms --no-lock; as we not necessary should run vms on every setup
  arraylength=${#files[@]}
  set +e
  for (( i=0; i<arraylength+1; i++ ));
  do
    if [[ $i -gt 0 ]]; then
      local file="${files[$i-1]}"
      information "${file}"
      if ! "${brewexec}" bundle --file="brew/${file}" --describe --no-lock -q; then
          error "failed to install ${file}! aborting..."
      fi
    fi
  done
  set -e
}

brew_uninstall() {
  set +e
  information "uninstall brew formula"
  declare -a formula=(
    "ruby"
    "ruby@2.7"
    "git-chglog"
  )

  for el in "${formula[@]}" ; do
    key="${el%%}"
    if brew list --formula | grep "${key}"; then
      information "uninstall formula: ${key}"
      brew uninstall "$key" -fq
    fi
  done

  # uninstall taps
  information "untap brew taps"
  declare -a taps=(
    "shopify/shopify"
    "git-chglog/git-chglog"
  )
  for el in "${taps[@]}" ; do
    key="${el%%}"
    if brew tap | grep "${key}"; then
      information "uninstall tap: ${key}"
      brew untap "$key" -fq
    fi
  done
  set -e
}

brew_lifecycle() {
  brew cu -y && brew update && brew upgrade
}

brew_cleanup() {
  brew autoremove && brew cleanup
}

brew_fix() {
  cd "$(brew --repository)"
  git --git-dir "$(brew --repository)/.git" reset origin/master --hard
  git --git-dir "$(brew --repository)/.git" clean -fd
}

brew_setup_all() {
  brew_install
  brew_lifecycle
  brew_cleanup
  brew_uninstall
}

if [[ -z "${INSTALL_BREW}" ]]; then
  brew_setup_all
else
  bot "brew update packages & install new packages from brewfiles"
  while true; do
      response=''
      read_input "run brew setup? [y|N] " response
      case $response in
          [Yyes]* )
            action "upgrade brew packages..."
            brew_setup_all
            ok "brews updated..."
            break;;
          [Nn]* )
            warn "skipped brew update"
            break;
            ;;
          * ) echo "Please answer yes or no.";;
      esac
  done
fi
