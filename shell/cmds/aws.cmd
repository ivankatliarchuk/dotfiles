#!/bin/env bash

_aws_show_help() {
cat << EOF
Commands that contains AWS Helpers

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display versions
    -d, --docs          Show awailable debug documentaions
        --docsopen      Open debug documentaions
EOF
}

function aws-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              _aws_show_help
              break
              ;;
            -a|--aliases)
              _aws_aliases
              break
              ;;
            -v|--versions)
                hub version
                break
                ;;
            -d|--docs)
              _aws_docs
              break
              ;;
            --docsopen)
              _aws_docs -o
              break
              ;;
            *)
              _aws_show_help
              break
              ;;
        esac

        shift
    done
}

function _aws_aliases() {
  information "aws: everything"
  alias | grep 'aws'
  alias | grep '^a\.'
}

function _aws_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://github.com/aws/aws-cli"
    "https://github.com/awslabs/awscli-aliases"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
    if [[ ${toOpen} ]]; then
      open "${KEY}"
    fi
  done
}
