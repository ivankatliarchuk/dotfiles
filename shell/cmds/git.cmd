#!/bin/env bash

_git_show_help() {
cat << EOF
Commands that contains Git Helpers

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display versions
    -d, --docs          Show awailable debug documentaions
        --docsopen      Open debug documentaions
EOF
}

function git-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              _git_show_help
              break
              ;;
            -a|--aliases)
              _git_aliases
              break
              ;;
            -v|--versions)
                hub version
                break
                ;;
            -d|--docs)
              _git_docs
              break
              ;;
            --docsopen)
              _git_docs -o
              break
              ;;
            *)
              _git_show_help
              break
              ;;
        esac

        shift
    done
}

function _git_aliases() {
  information "git: everything"
  alias | grep 'git'
  information "git: fgit"
  alias | grep 'fgit'
  information " branch"
  alias | grep 'git branch'
  information "git: configuration"
  git aliases | grep config
}

function _git_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://docs.github.com/en"
    "https://hub.github.com"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
    if [[ ${toOpen} ]]; then
      open "${KEY}"
    fi
  done
}
