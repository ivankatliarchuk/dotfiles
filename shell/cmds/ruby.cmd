#!/bin/env bash

ruby_show_help() {
cat << EOF
Commands to troubleshot Ruby

Documentation https://bundler.io/doc/troubleshooting.html

Usage: $(basename "$0") <options>
    -h, --help          Display help
    -a, --aliases       Display awailable aliases
    -v, --versions      Display ruby versions
    -d, --docs          Open documentaions
    -u, --update        Update to the latest version of bundler
    -t, --troubleshoot  You can try these troubleshooting steps
EOF
}

function rubyhelp() {

  while :; do
        case "${1:-}" in
            -h|--help)
              ruby_show_help
              break
              ;;
            -a|--aliases)
              ruby_aliases
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
              open https://bundler.io/doc/troubleshooting.html
              break
              ;;
            -t|--troubleshoot)
              ruby_troubleshoot
              break
              ;;
            *)
              echo "not implemented command."
              ruby_show_help
              break
              ;;
        esac

        shift
    done
}

function rversions() {
  echo "Bundler version: $(bundle -v)"
  echo "Ruby version: $(ruby -v)"
  echo "Gem version: $(gem -v)"
}

function ruby_troubleshoot() {
  echo "# Remove user-specific gems and git repos"
  echo "rm -rf ~/.bundle/ ~/.gem/bundler/ ~/.gems/cache/bundler/"

  echo "# Remove system-wide git repos and git checkouts"
  echo "rm -rf $GEM_HOME/bundler/ $GEM_HOME/cache/bundler/"

  echo "# Remove project-specific settings"
  echo "rm -rf .bundle/"

  echo "# Remove project-specific cached gems and repos"
  echo "rm -rf vendor/cache/"

  echo "# Remove the saved resolve of the Gemfile"
  echo "rm -rf Gemfile.lock"

  echo "# Uninstall the rubygems-bundler and open_gem gems"
  echo "rvm gemset use global"
  echo "gem uninstall rubygems-bundler open_gem"
}

function ruby_aliases() {
  alias | grep 'gem'
  alias | grep 'rvm'
}
