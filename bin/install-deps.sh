#!/bin/bash

set -e

: "${GVM_NO_UPDATE_PROFILE:=1}"

[[ -n "${DEBUG:-}" ]] && set -x

exists() {
  command -v "$1" >/dev/null 2>&1
}

show_help() {
cat << EOF
Usage: $(basename "$0") :do:
    install powerline fonts
    install gvm (Go Version Manager)
    install helm charts
EOF
}

install_fonts() {
  pushd vendor/powerline-fonts > /dev/null
    echo "here 1: ${PWD}"
    ./install.sh
  popd
}

install_gvm() {
  if ! exists gvm; then
    $SHELL < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) || echo "installed"
  fi
}

install_helm() {
  scripts/helm.add.repo
}

show_help
install_fonts
install_gvm
install_helm
