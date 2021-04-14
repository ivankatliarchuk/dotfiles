#!/bin/bash
# shellcheck disable=SC2155
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/bin/install-deps.sh

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
    install python with Pyenv (https://realpython.com/intro-to-pyenv)
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
  if ! exists nvm; then
    # installed with brwe
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    # install default from ~/.nvmrc
    echo "install nvm with brew"
  else
    nvm use
  fi
}

install_rvm() {
  set +e
  if ! exists rvm; then
  # install default from ~/.nvmrc
    command curl -sSL https://rvm.io/mpapis.asc | gpg --import - ||
      command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
  else
    rvm get stable --auto-dotfiles
    rvm list gemsets
    gem update --system || echo "Failed update :gem: gems"
  fi
  set -e
}

install_helm() {
  scripts/helm.add.repo
}

show_help
install_fonts
install_gvm
install_node
# install_rvm
install_helm
