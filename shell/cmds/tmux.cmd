#!/bin/env bash

tmux_show_help() {
cat << EOF
Commands to troubleshot tmux

Documentation https://github.com/tmux/tmux/wiki

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display tmux versions
    -d, --docs          View awailable documentaion
        --docsopen      Open debug documentaions
EOF
}

function tmux-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              tmux_show_help
              break
              ;;
            -a|--aliases)
              tmux_aliases
              break
              ;;
            -v|--versions)
                rversions
                break
                ;;
            -u|--update)
              gem install bundler
              break
              ;;
            -d|--docs)
              tmux_docs
              break
              ;;
            --docsopen)
              tmux_docs -o
              break
              ;;
            -t|--troubleshoot)
              tmux_troubleshoot
              break
              ;;
            *)
              tmux_show_help
              break
              ;;
        esac

        shift
    done
}

function rversions() {
  tmux -V
  tmuxp --version
}

function tmux_troubleshoot() {
  information "troubleshooting steps"
}

function tmux_aliases() {
  information "tmux: everthing"
  alias | grep 'tmux'
  information "tmuxp: everthing"
  alias | grep 'tmuxp'
}

function tmux_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://github.com/tmux/tmux/wiki"
    "https://tmuxp.git-pull.com"
    "https://github.com/rothgar/awesome-tmux"
  )
  for el in "${docs[@]}" ; do
    key="${el%%}"
    information "doc > ${key}"
    if [[ ${toOpen} ]]; then
      open "${key}"
    fi
  done
}
