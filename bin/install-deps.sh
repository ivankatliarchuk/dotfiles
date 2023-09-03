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
NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
RUBY_VERSION=2.7.0

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

exists() {
  command -v "$1" >/dev/null 2>&1
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
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    # install default from ~/.nvmrc
    echo "install nvm with brew"
  else
    nvm use
  fi
}

# https://github.com/rvm/rvm
# rvm list known
# rvm install ruby@latest
# rvm use ruby-X.X.X --default
# rvm gemset use global
# sudo gem update --system
install_rvm() {
  set +e
  if ! exists rvm; then
  # install default from ~/.nvmrc
    command curl -sSL https://rvm.io/mpapis.asc | gpg --import - ||
      command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
  else
    rvm --default use ${RUBY_VERSION}
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

install_python() {
  action "$1"
  pyenv local && python3 -m pip install -U -r py/requirements.txt && python3 -m pip install --upgrade pip
  ok "$1"
}

install_osx() {
  action "$1"
  tools/os/setup.sh
  ok "$1"
}

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

core() {
  no_input='Please answer yes or no.'
  msg='install/update and reset fonts cache'
  install_local "install_fonts" "$msg"

  msg='install gvm'
  install_local "install_gvm" "$msg"

  msg='install & update helm repositories'
  install_local "install_helm" "$msg"

  msg='install & update python and pyenv'
  install_local "install_python" "$msg"

  msg='sync OSX settings'
  install_local "install_osx" "$msg"
}


usage() {
  echo "Usage: for $0"
cat << EOF

Documentation https://github.com/ivankatliarchuk/dotfiles

Usage: $(basename "$0") <options>
    -h, --help       Display help
    -a, --all        Run all
    -n, --node       Install Node
    -g, --go         Install GVM for Go sdk
    -p, --python     Install Python and Pyenv
    -o, --osx        Sycn OSX settings
EOF
}

cmds() {
  while :; do
    case "${1:-}" in
        -a|--all)
          core
          break
          ;;
        -n|--node)
          install_node
          break
          ;;
        -g|--go)
          install_gvm "$@"
          break
          ;;
        -p|--python)
          install_python "$@"
          break
          ;;
        -o|--osx)
          install_osx "$@"
          break
          ;;
        -h|--help)
          usage
          break
          ;;
        *)
          core
          break
          ;;
    esac
    shift
  done
}

cmds "$@"
