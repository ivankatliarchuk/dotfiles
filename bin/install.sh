#!/bin/bash

[[ -n "${DEBUG:-}" ]] && set -x

usage() {
  echo "Usage: for $0"
cat << EOF

Documentation https://github.com/ivankatliarchuk/dotfiles

Usage: $(basename "$0") <options>
    -h, --help       Display help
    -a, --all        Run all
    -n, --no-shell   Run without shell
    -v, --versions   Display ruby versions
    -d, --docs       View awailable documentaion
EOF
}

cmds() {
  while :; do
    case "${1:-}" in
        -a|--all)
          execute
          break
          ;;
        -n|--no-shell)
          execute --except shell
          break
          ;;
        -h|--help)
          usage
          break
          ;;
        -d|--docs)
          _docs
          break
          ;;
        *)
          usage
          break
          ;;
    esac
    shift
  done
}

function _docs() {
  declare -a docs=(
    "https://github.com/ivankatliarchuk/dotfiles"
    "https://github.com/anishathalye/dotbot"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
  done
}

git-submodule() {
  # shellcheck disable=SC2034
  BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  git clean -dxf
  git reset --hard
  git diff | git apply --reverse
  git config pull.ff only
  git pull
  git submodule sync --recursive
  git submodule update --init --recursive
}

execute() {

  bin/install "$@"
}

cmds "$@"
