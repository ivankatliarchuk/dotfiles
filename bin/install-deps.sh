#!/bin/bash
# shellcheck disable=SC2155

set -e

: "${GVM_NO_UPDATE_PROFILE:=1}"
: "${PYENV_VERSION:=3.9.1}"

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
    install python with Pyenv (https://realpython.com/intro-to-pyenv/)
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

install_python() {
  local python_versions="$(pyenv versions | tr -d '[:space:]')"
  local pyenv_latest_version="$(pyenv install --list | grep -v - | grep -v b | tail -1 | tr -d '[:space:]')"
  if [ ! -x "$(command -v pyenv)" ]; then
    pyenv install --skip-existing "${PYENV_VERSION}"
    pyenv global "${PYENV_VERSION}"
    echo "pip location: $(pyenv which pip)"
  else
    echo "pyenv not installed"
  fi

  if [ ! -x "$(command -v pyenv)" ]; then

  if [[ ! ${python_versions} =~ ${pyenv_latest_version} ]]; then
    echo "new pyethon version is awailable ${pyenv_latest_version}"
  fi
fi
}

install_rvm() {
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
}

install_helm() {
  scripts/helm.add.repo
}

show_help
install_fonts
install_gvm
install_node
install_rvm
install_python
install_helm
