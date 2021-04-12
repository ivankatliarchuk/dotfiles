#!/bin/bash

set -e


[[ -n "${DEBUG:-}" ]] && set -x

exists() {
  command -v "$1" >/dev/null 2>&1
}

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
  # "Brewfile.fonts"
  declare -a files=(
    "Brewfile"
    "Brewfile.secure"
    "Brewfile.networking"
    "Brewfile.git"
    "Brewfile.aws"
    "Brewfile.development"
    "Brewfile.k8s"
  )
  arraylength=${#files[@]}
  set +e
  for (( i=1; i<arraylength+1; i++ ));
  do
    echo "${i} ${files[$i-1]}"
    $(which brew) bundle --file="brew/${files[$i-1]}" --describe --no-lock -q
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

show_help
brew_install
brew_lifecycle
brew_cleanup
