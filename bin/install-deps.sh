#!/bin/bash

set -ex

cd vendor/powerline-fonts

./install.sh

exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! exists gvm; then
  $SHELL < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi
