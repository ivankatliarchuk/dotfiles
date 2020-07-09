#!/bin/bash

CONFIG=dotbot.conf.yaml
dbot=$(which dotbot)

usage() { echo "Usage: $0 [-t <local|remote>]" 1>&2; exit 1; }

while getopts ":t:" option; do
  case $option in
    t) TARGET="$OPTARG";;
		*) usage;;
  esac
done

: "${TARGET}"

if [ "$TARGET" = "local" ]; then
BASEDIR="$(pwd)"

bin/install \
  --plugin-dir vendor/dotbot-brew \
  --plugin-dir vendor/dotbot-pip

else
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git clean -dxf
git reset --hard
git diff | git apply --reverse
git config pull.ff only
git pull
git submodule sync --recursive
git submodule update --init --recursive

${dbot} -c "${BASEDIR}/${CONFIG}" -d "${BASEDIR}" \
  --plugin-dir vendor/dotbot-brew \
  --plugin-dir vendor/dotbot-pip
fi
