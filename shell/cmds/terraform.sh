#!/bin/env bash
# shellcheck disable=SC2155,SC2086,SC2046

tf_show_help() {
cat << EOF
Commands that contains Terraform Helpers

Documentation https://www.terraform.io/docs/language/functions/index.html
Documentation https://terragrunt.gruntwork.io/

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display versions
    -u, --update        Update/Switch Terarform|Terragrunt version
    -d, --docs          Show awailable debug documentaions
        --docsopen      Open debug documentaions
EOF
}

function tf-help() {

  while :; do
        case "${1:-}" in
            -h|--help)
              tf_show_help
              break
              ;;
            -a|--aliases)
              tf_aliases
              break
              ;;
            -v|--versions)
              tf_versions
              break
              ;;
            -u|--update)
              tfswitch
              tgswitch
              break
              ;;
            -d|--docs)
              tf_docs
              break
              ;;
            --docsopen)
              tf_docs -o
              break
              ;;
            *)
              tf_show_help
              break
              ;;
        esac

        shift
    done
}

function tf_aliases() {
  alias | grep 'terra'
}

function tf_versions() {
  echo "Bundler version: $(bundle -v)"
  echo "Ruby version: $(ruby -v)"
  echo "Gem version: $(gem -v)"
}

function tf_docs() {
  local toOpen="$1"
  declare -a docs=(
    "https://www.terraform.io/docs/language/functions/index.html"
    "https://learn.hashicorp.com/terraform?utm_source=terraform_io"
    "https://terragrunt.gruntwork.io/"
  )
  for el in "${docs[@]}" ; do
    KEY="${el%%}"
    printf "doc > %s\n" "${KEY}"
    if [[ ${toOpen} ]]; then
      open "${KEY}"
    fi
  done
}

# OPINIONATED COMMANDS (require AWS-VAULT)

# Terraform
tfinit() {
  tfrun init "${@:1}"
}

tfplan() {
  tfrun plan "${@:1}"
}

tfapply() {
  tfrun apply "${@:1}"
}

# TODO
# 1. remove hbi or parametrize it
tfrun() {
  local ENVIRONMENTS=$(find ../environments -type f -name terraform.tfvars)
  # Filter options based on provided arguments
  for filter in "${@:2}"; do
    if [[ "$filter" != "" ]]; then
      ENVIRONMENTS=$(echo $ENVIRONMENTS | grep $filter)
    fi
  done

  # Exit if no options
  local count=$(echo $ENVIRONMENTS | wc -l)
  if [[ "$ENVIRONMENTS" == "" ]]; then
    echo "No matching environments"
    return
  fi

  # Only fuzzy-find if there is more than one option
  if [[ $count -eq 1 ]]; then
    local SELECTED=$ENVIRONMENTS
  else
    local SELECTED=$(echo $ENVIRONMENTS | fzf)
    if [[ "$SELECTED" == "" ]]; then
      echo "Cancelled"
      return
    fi
  fi
  TF_CONFIG=${SELECTED//terraform.tfvars}

  local ACTION=$1
  # Change action based on existence of backend.tfvars file
  if [ ! -f "$TF_CONFIG/backend.tfvars" ]; then
    ACTION="initjson"
  fi

  ENV=$(echo $SELECTED|cut -d/ -f3)

  case "$ACTION" in
    '')
      echo "ERROR: No command passed for aws-vault to run"
    ;;
    init)
      aws-vault exec "hbi-$ENV" -- terraform init -reconfigure -backend-config="${TF_CONFIG}backend.tfvars"
    ;;
    initjson)
      COMPONENT=$(basename $(dirname $PWD))
      ENV=$(echo $SELECTED|cut -d/ -f3)
      REGION=$(echo $SELECTED|cut -d/ -f4)
      INSTANCE=$(echo $SELECTED|cut -d/ -f5|grep -v terraform.tfvars)
      echo INSTANCE=$INSTANCE -V ENV=$ENV -V REGION=$REGION -V COMPONENT=$COMPONENT

      jsonnet -V INSTANCE=$INSTANCE -V ENV=$ENV -V REGION=$REGION -V COMPONENT=$COMPONENT -S -m "../environments/$ENV/$REGION/$INSTANCE ../../.gitlab/backend-tfvars.jsonnet"
      aws-vault exec "hbi-$ENV" -- terraform init -reconfigure -backend-config="../environments/$ENV/$REGION/$INSTANCE/backend.tfvars"
    ;;
    plan)
      aws-vault exec "hbi-$ENV" -- terraform plan -var-file="$SELECTED" -out=plan.out
    ;;
    apply)
      aws-vault exec "hbi-$ENV" -- terraform apply plan.out
      rm plan.out
    ;;
  esac
}
