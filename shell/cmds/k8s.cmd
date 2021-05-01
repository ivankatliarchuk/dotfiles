#!/bin/env bash

_k8s_show_help() {
cat << EOF
Kubernetes helper commands

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display versions
    -d, --docs          Show awailable debug documentaions
        --docsopen      Open debug documentaions
EOF
}

function k8s-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              _git_show_help
              break
              ;;
            -a|--aliases)
              _k8s_aliases
              break
              ;;
            -v|--versions)
                _k8s_versions
                break
                ;;
            -d|--docs)
              _k8s_docs
              break
              ;;
            --docsopen)
              _k8s_docs -o
              break
              ;;
            *)
              _k8s_show_help
              break
              ;;
        esac

        shift
    done
}

function _k8s_versions() {
  kubectl version
}

function _k8s_aliases() {
  information "k8s: everything"
  alias | grep 'kub'
}

function _k8s_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://kubernetes.io"
    "https://k8s.af"
    "https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html"
    "https://bcouetil.gitlab.io/academy/BP-kubernetes.html"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
    if [[ ${toOpen} ]]; then
      open "${KEY}"
    fi
  done
}
