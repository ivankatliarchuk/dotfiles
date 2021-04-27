#!/bin/bash
# shellcheck disable=SC2155
# https://raw.githubusercontent.com/ivankatliarchuk/dotfiles/master/bin/install-deps.sh

set -ex

: "${PYENV_USE_GLOBAL:=false}"
: "${PYENV_LOCATION}"

if [[ -f .python-version  ]]; then
  export PYENV_VERSION=$(cat .python-version)
fi

[[ -n "${DEBUG:-}" ]] && set -x

exists() {
  command -v "$1" >/dev/null 2>&1
}

show_help() {
cat << EOF
Usage: $(basename "$0") :do:
    install python with Pyenv (https://realpython.com/intro-to-pyenv)
EOF
}

install_python_version() {
  local python_versions="$(pyenv versions | tr -d '[:space:]')"
  local pyenv_latest_version="$(pyenv install --list | grep -v - | grep -v b | tail -1 | tr -d '[:space:]')"
  # @todo: validate versions!!
  # if [ ! -x "$(command -v pyenv)" ]; then
    ${PYENV_LOCATION} install --skip-existing "${PYENV_VERSION}"
    ${PYENV_LOCATION} rehash
    if "${PYENV_USE_GLOBAL}" ; then
      ${PYENV_LOCATION} local "${PYENV_VERSION}"
    else
      ${PYENV_LOCATION} global "${PYENV_VERSION}"
    fi
    echo "pip location: $(pyenv which pip)"
  # else
  #   echo "pyenv not installed"
  # fi

  if [[ ! ${python_versions} =~ ${pyenv_latest_version} ]]; then
    echo "new pyethon version is awailable ${pyenv_latest_version}"
  fi
}

install_python_version
