# CloudKat's dotfiles

Dotfiles setup

[![](https://github.com/ivankatliarchuk/dotfiles/workflows/release/badge.svg)](https://github.com/ivankatliarchuk/dotfiles/actions?query=workflow%3Arelease)
[![](https://img.shields.io/github/license/ivankatliarchuk/dotfiles)](https://github.com/ivankatliarchuk/dotfiles)
[![](https://img.shields.io/github/repo-size/ivankatliarchuk/dotfiles)](https://github.com/ivankatliarchuk/dotfiles)
![](https://img.shields.io/github/languages/top/ivankatliarchuk/dotfiles?color=green&logo=bash&logoColor=blue)
![](https://img.shields.io/github/commit-activity/m/ivankatliarchuk/dotfiles)
![](https://img.shields.io/github/last-commit/ivankatliarchuk/dotfiles)
![](https://img.shields.io/github/contributors/ivankatliarchuk/dotfiles)
[![GitHub forks](https://img.shields.io/github/forks/ivankatliarchuk/dotfiles.svg?style=social&label=Fork)](https://github.com/ivankatliarchuk/dotfiles)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Project Structure](#project-structure)
- [Installation](#installation)
- [Caveats](#caveats)
- [Motivation](#motivation)
- [🔖 Documentation](#-documentation)
  - [Evaluate Tools](#evaluate-tools)
  - [®️ Emojies](#%EF%B8%8F-emojies)
  - [Commands](#commands)
- [#️⃣ TODO](#%EF%B8%8F%E2%83%A3-todo)
- [Awailable Commands](#awailable-commands)
- [GPG keys](#gpg-keys)
  - [📝 Guidelines](#-guidelines)
- [🔖 License](#-license)
- [How to Contribute](#how-to-contribute)
- [Authors](#authors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Project Structure

```
.
├── bin
├── brew
├── docs
├── git
│   ├── gitattributes
│   ├── gitcfg
│   ├── gitconfig
│   └── gitconfig.include
├── locals
├── py
├── scripts
├── shell
├── terminal
│   ├── iTerm
│   ├── starship
│   └── zellij
├── tools               # gnupg, vim, browser, os, mise, and other tool configs
├── vendor
├── zsh
├── LICENSE
├── Makefile
├── mise.toml
└── README.md
```

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

Symlinks are installed via [mise](https://mise.jdx.dev/dotfiles.html): `bin/install` runs `mise bootstrap dotfiles apply` against the `[dotfiles]` table in `mise.toml`. This replaces [Dotbot](https://github.com/anishathalye/dotbot), which this repo used previously.

mise also manages the rest of the machine bootstrap from the same `mise.toml`:

- `make mise-install` installs the dev tools pinned in `tools/mise/config.toml` (node, go, ...); `make mise-lock-global` regenerates their lockfile/checksums (`tools/mise/mise.lock`).
- `make macos-defaults-status` shows drift between `mise.toml`'s `[bootstrap.macos.*]` tables and the machine's current macOS preferences; `make macos-defaults-apply` writes them for real.

## Caveats

These scripts are meant to run only on OS X

## Motivation

- [ThoughBot](https://github.com/thoughtbot/dotfiles)
- [Dotfiles](https://dotfiles.github.io/)
- [Dotfiles: awesome](https://project-awesome.org/webpro/awesome-dotfiles)

## 🔖 Documentation

- [Bash Hacks](docs/bash-hints.md)
- [Tools and guides](docs/tools.md)
- [debug](docs/tools.md#debug-zsh)

### Evaluate Tools

- [Cyberduck](https://cyberduck.io/)

### ®️ Emojies

- [Emoji: github](https://github.com/ikatyang/emoji-cheat-sheet)

### Commands

```sh
git check-ignore -v tools/claude/plans/
```

## #️⃣ TODO

- ✅ ZSH (zsh-config)
- ✅ Tmuxp configuration (tmux-config) path = vendor/tmux-config
- ✅ Docker RMI alias
- ✅ Badges
- ✅ Github Hooks
- ✅ Move configs to own folders
- ✅ Install powerline fonts
- ✅ wgetrc & curlrc
- ✅ Pyenv correct setup
- ✅ Proper configre macup
- ✅ Tmux configs Setup/Document
- ✅ macOS setup [docs](tools/os/readme.md)
- [X] Speed up shell
- [ ] ZSH plugins https://github.com/zsh-users/zsh-autosuggestions/tree/master?tab=readme-ov-file
- [ ] POV [Yadm: dotfiles manager](https://formulae.brew.sh/formula/yadm)
- [ ] Firefox [auto config docs](tools/browser/firefox/readme.md)
- [ ] Hammersppoon config opensource [docs](tools/hammerspoon/readme.md)
- [ ] Chezmoi integration
- [ ] Support Linux/Debian
- [ ] [DNS Crypt](https://github.com/drduh/config/blob/master/dnscrypt-proxy.toml)
- [ ] Document github setup, blog it as well
- [ ] Templated dotfiles (mise supports `mode = "template"` natively now, no plugin needed - just not adopted anywhere yet)
- [X] Review new Terminal Options

## Awailable Commands

<!-- START makefile-doc -->
```
$ make help
Usage: make [target] [VARIABLE=value]
Targets:
install                        Install dotfiles without running shell
install-all                    Install all dotfiles
brew-install                   Install apps with Brew
osx-install                    Install macOSx
macos-defaults-status          Show drift between mise.toml and current macOS defaults
macos-defaults-apply           Apply macOS defaults from mise.toml (writes real system prefs)
mise-install                   Install tools from mise.toml (node, go, ...)
mise-lock-global               Regenerate the global mise.lock (tools/mise/mise.lock)
hooks                          Setup pre commit.
validate                       Validate files with pre-commit hooks
ignore-dirty                   Ignore dirty commits
install-deps                   Install dependencies
git-submodule                  Git submodules update
git-module-remove              Remove submodule MODULE=something
open                           Open repository
```
<!-- END makefile-doc -->

## GPG keys

- [How to](https://docs.github.com/en/authentication/managing-commit-signature-verification/checking-for-existing-gpg-keys)
- [How to v2](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key)
- [How to test](https://claytonerrington.com/blog/view-public-gpg-fingerprints/)

### 📝 Guidelines

- 📝 Use a succinct title and description.
- 🦠 Bugs & feature requests can be be opened
- 📶 Support questions are better asked on [Stack Overflow](https://stackoverflow.com/)
- 😊 Be nice, civil and polite ([as always](http://contributor-covenant.org/version/1/4/)).

## 🔖 License

Copyright 2019 Ivan Katliarhcuk

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## How to Contribute

Submit a pull request

## Authors

Currently maintained by [Ivan Katliarchuk](https://github.com/ivankatliarchuk) and these [awesome contributors](https://github.com/ivankatliarchuk/dotfiles/graphs/contributors).

[![ForTheBadge uses-git](http://ForTheBadge.com/images/badges/uses-git.svg)](https://GitHub.com/)
