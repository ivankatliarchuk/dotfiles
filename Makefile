SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

help:
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

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

install-local: ## Install locally
	@bin/install.sh -t local

ignore-dirty: ## Ignore dirty commits
	@git config --file .gitmodules --get-regexp path | awk '{ print $2 }'
	@git config -f .gitmodules submodule.vendor/bash-it.ignore dirty
	@git config -f .gitmodules submodule.vendor/prezto.ignore dirty
	@git config -f .gitmodules submodule.vendor/powerline-fonts.ignore dirty
	@git config -f .gitmodules submodule.vendor/dotbot.ignore dirty

install-deps: ## Install dependencies
	@bin/install-deps.sh

.PHONY: git-submodule
git-submodule:
	@git submodule sync --recursive
	@git submodule foreach git pull origin master
	@git submodule update --init --recursive --progress

git-module-remove: ## Remove submodule MODULE=something
	@git submodule deinit -f vendor/$(MODULE)
	@git rm --cached vendor/$(MODULE)

brew-install: ## Install Brew
	@brew bundle --file=brew/Brewfile.secure -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.secure -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.networking -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.git -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.aws -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.fonts -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.development -v --describe --no-lock
	@brew bundle --file=brew/Brewfile.k8s -v --describe --no-lock

.PHONY: vm-up vm-dowm validate hooks brew-install
