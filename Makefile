SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

INSTALL_BREW ?= false

include tools/mise/helper.mk

help:
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install dotfiles without running shell
	-@bin/install.sh --no-shell

install-all: ## Install all dotfiles
	-@bin/install.sh --all

brew-install: ## Install apps with Brew
	@brew bundle --file=brew/Brewfile.current;

osx-install: ## Install macOSx
	@tools/os/setup.sh

hooks: ## Setup pre commit.
	@pre-commit install
	@pre-commit gc
	@pre-commit autoupdate

validate: ## Validate files with pre-commit hooks
	@pre-commit run --all-files

ignore-dirty: ## Ignore dirty commits
	@git config --file .gitmodules --get-regexp path | awk '{ print $2 }'
	@git config -f .gitmodules submodule.vendor/powerline-fonts.ignore dirty

install-deps: ## Install dependencies
	@bin/install-deps.sh

git-submodule: ## Git submodules update
	@git submodule sync --recursive
	@git submodule foreach git pull origin master
	@git submodule update --init --recursive --progress

git-module-remove: ## Remove submodule MODULE=something
	@git submodule deinit -f vendor/$(MODULE)
	@git rm --cached vendor/$(MODULE)

open: ## Open repository
	@open $(shell git config --get remote.origin.url)

shell-bench: ## Time 5 new login shells (what a new terminal tab costs)
	@for i in 1 2 3 4 5; do /usr/bin/time -p zsh -l -i -c exit 2>&1 >/dev/null | grep real; done

.PHONY: validate hooks brew-install git-submodule shell-bench
