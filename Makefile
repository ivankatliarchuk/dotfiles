SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

INSTALL_BREW ?= false
export PYENV_LOCATION ?= $(shell which pyenv)

help:
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install dotfiles without running shell
	-@bin/install.sh --no-shell

install-all: ## Install all dotfiles
	-@bin/install.sh --all

brew-install: ## Install apps with Brew
	# todo: install brew as well if not set
	-@./brew/setup.sh
	# todo: move to set.sh
	@brew bundle --file=brew/Brewfile.mas --no-lock;

osx-install: ## Install macOSx
	@tools/os/setup.sh

hooks: ## Setup pre commit.
	@pre-commit install
	@pre-commit gc
	@pre-commit autoupdate

validate: ## Validate files with pre-commit hooks
	@pre-commit run --all-files

vm-up: ## Run on Mac. Up
	@vagrant up

vm-dowm: ## Run on Mac. Down
	@vagrant down

ignore-dirty: ## Ignore dirty commits
	@git config --file .gitmodules --get-regexp path | awk '{ print $2 }'
	@git config -f .gitmodules submodule.vendor/bash-it.ignore dirty
	@git config -f .gitmodules submodule.vendor/prezto.ignore dirty
	@git config -f .gitmodules submodule.vendor/powerline-fonts.ignore dirty
	@git config -f .gitmodules submodule.vendor/dotbot.ignore dirty

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

.PHONY: vm-up vm-dowm validate hooks brew-install git-submodule
