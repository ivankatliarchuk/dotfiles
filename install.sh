#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG=dotbot.conf.yaml
dbot=$(which dotbot)

git pull
git submodule sync --recursive
git submodule update --init --recursive

${dbot} -c ${CONFIG} -d "${BASEDIR}" --plugin-dir vendor/dotbot-brew --plugin-dir vendor/dotbot-pip "${@}"
