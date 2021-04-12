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
    install node with NVM (Node Version Manage https://github.com/nvm-sh/nvm)
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
  # rm -rf ~/.gvm
  if ! exists gvm; then
    $SHELL < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) || echo "installed"
    # gvm install go1.16
    # gvm use
  fi
}

install_node() {
  if exists nvm; then
  # install default from ~/.nvmrc
    nvm use
  fi
}

install_helm() {
  scripts/helm.add.repo
}

show_help
install_fonts
install_gvm
install_node
install_helm
