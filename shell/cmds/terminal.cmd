#!/bin/env bash

terminal_show_help() {
cat << EOF
Commands to troubleshot Terminal performance

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display versions
    -d, --docs          Show awailable debug documentaions
        --docsopen      Open debug documentaions
    -s, --starshipdebug You can try these 'starhip' troubleshooting steps
    -z, --zshdebug      You can try these 'zsh' troubleshooting steps
EOF
}

function terminal-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              terminal_show_help
              break
              ;;
            -a|--aliases)
              terminal_aliases
              break
              ;;
            -v|--versions)
                break
                ;;
            -s|--starshipdebug)
              starship timings
              break
              ;;
            -z|--zshdebug)
              echo "to debug 'zsh -x'"
              echo "when done: 'zsh +x'"
              break
              ;;
            -d|--docs)
              terminal_docs
              break
              ;;
            --docsopen)
              terminal_docs -o
              break
              ;;
            -t|--troubleshoot)
              terminal_troubleshoot
              break
              ;;
            *)
              terminal_show_help
              break
              ;;
        esac

        shift
    done
}

function terminal_aliases() {
  alias | grep 'zsh'
  alias | grep 'cmd'
  alias | grep 'help'
}

function terminal_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://carlosbecker.com/posts/speeding-up-zsh"
    "https://blog.askesis.pl/post/2017/04/how-to-debug-zsh-startup-time.html"
    "https://memo.ecp.plus/optimize_zshrc"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
    if [[ ${toOpen} ]]; then
      open "${KEY}"
    fi
  done
}
