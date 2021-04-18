#!/bin/bash
# shellcheck disable=SC2155
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/bin/install-deps.sh

set -e

: "${GVM_NO_UPDATE_PROFILE:=1}"

[[ -n "${DEBUG:-}" ]] && set -x
# shellcheck source=/dev/null
[[ -f "scripts/utils" ]] && source scripts/utils
# @todo: renovate should support that
# renovate: datasource=github-releases depName=nvm-sh/nvm versioning=loose
NVM_VERSION=v0.36.0

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
  action "$1"
  pushd vendor/powerline-fonts > /dev/null
    ./install.sh
  popd
  ok "$1"
}

install_gvm() {
  action "$1"
  local noerr=true
  [[ -d "${HOME}/.gvm" ]] && echo "exist"
  if ! exists gvm; then
    [[ -d "${HOME}/.gvm" ]] && rm -rf "${HOME}/.gvm"
    if ! $SHELL < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer); then
      error "failed '$1' aborting..."
      noerr=false
    fi
    # gvm install go1.16
    # gvm use
  fi
  if [[ -z "${noerr}" ]]; then
    ok "$1"
  fi
}

install_node() {
  if ! exists nvm; then
    # installed with brwe
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
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
  action "$1"
  scripts/helm.add.repo
  ok "$1"
}

# show_help
# install_node
# install_rvm

install_local() {
local command=$1
local arg=$2
bot "${arg}"
while true; do
    response=''
    read_input "${arg}? [y|N] " response
    case $response in
        [Yyes]* )
          $command "$arg"
          break;;
        [Nn]* )
          warn "skipped ${arg}"
          break;
          ;;
        * ) warn "$no_input";;
    esac
done
}

no_input='Please answer yes or no.'
msg='install/update and reset fonts cache'
install_local "install_fonts" "$msg"

msg='install gvm'
install_local "install_gvm" "$msg"

msg='install & update helm repositories'
install_local "install_helm" "$msg"
