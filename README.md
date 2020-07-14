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

## Table of Contents

- [CloudKat's dotfiles](#cloudkat-s-dotfiles)
  * [Table of Contents](#table-of-contents)
  * [Project Structure](#project-structure)
  * [Prerequisits](#prerequisits)
  * [Installation](#installation)
  * [Caveats](#caveats)
  * [Motivation](#motivation)
  * [Dotbot Plugins](#dotbot-plugins)
  * [Brew](#brew)
  * [Tools](#tools)
  * [Documentation](#documentation)
  * [MacOS](#macos)
  * [Speed UP ZSH](#speed-up-zsh)
  * [Awailable Commands](#awailable-commands)
    + [:memo: Guidelines](#-memo--guidelines)
  * [License](#license)
  * [How to Contribute](#how-to-contribute)
- [Authors](#authors)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Project Structure

```
	.
	├── bin
	├── brew
	├── browser
	│   ├── firefox
	│   └── tor
	├── git
	│   ├── gitattributes
	│   ├── gitcfg
	│   ├── gitconfig
	│   └── gitconfig.include
	├── gnupg
	├── iTerm
	├── install.conf.yaml
	├── locals
	├── py
	├── scripts
	├── shell
	├── tmux
	├── tools
	├── vendor
	├── vim
	└── zsh
	├── LICENSE
	├── Makefile
	├── Vagrantfile
	└── README.md
```

## Prerequisits

- [DotBot](https://github.com/anishathalye/dotbot#configuration)

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

## Caveats

These scripts are meant to run only on OS X

## Motivation

- [ThoughBot](https://github.com/thoughtbot/dotfiles)
- [Dotfiles](https://dotfiles.github.io/)

## Dotbot Plugins

## Brew

- [Bundle](https://github.com/Homebrew/homebrew-bundle)
- [WhaleBrew](https://github.com/whalebrew/whalebrew)
- [MackUP](https://github.com/lra/mackup)

## Tools

- https://github.com/drduh/config/blob/master/dnscrypt-proxy.toml

## Documentation

- [DotBot](https://github.com/anishathalye/dotbot/wiki)
- [Chezmoi Quick Start](https://www.chezmoi.io/docs/quick-start/)

- [Github Hub](https://hub.github.com/)

- [PyEnv](https://realpython.com/intro-to-pyenv)

- [iTerm](https://sourabhbajaj.com/mac-setup/iTerm/)
- [Starship](https://starship.rs/)
- [Hyper](https://github.com/vercel/hyper)
- [Hyper Blog](https://www.robertcooper.me/elegant-development-experience-with-zsh-and-hyper-terminal)

- [Fasd](https://github.com/clvv/fasd)
- [Z](https://github.com/rupa/z)

- [Prezto](https://github.com/sorin-ionescu/prezto)

- [Ybikey Guide](https://github.com/drduh/YubiKey-Guide)

### Evaluate Tools

- [Cyberduck](https://cyberduck.io/)

## MacOS

- https://github.com/mathiasbynens/dotfiles/blob/main/.macos
- https://github.com/BarryMode/macos-prime/blob/master/dotfiles/.macos
- https://github.com/powerline/fonts
- https://github.com/drduh/macOS-Security-and-Privacy-Guide

## Speed UP ZSH

- https://carlosbecker.com/posts/speeding-up-zsh/
- https://gist.github.com/ctechols/ca1035271ad134841284
- https://blog.askesis.pl/post/2017/04/how-to-debug-zsh-startup-time.html
- https://memo.ecp.plus/optimize_zshrc/

> TODO

- [X] ZSH (zsh-config)
- [X] Tmuxp configuration (tmux-config) path = vendor/tmux-config
- [X] Docker RMI alias
- [X] Badges
- [X] Github Hooks
- [X] Move configs to own folders
- [X] Install powerline fonts
- [X] wgetrc & curlrc
- [ ] Move shell to same dir
- [ ] Document Tmux
- [ ] Mac setu pfrom here https://github.com/bitwolfe/dotbot#activity-monitor
- [ ] Correctly isntall nerd fonts
- [ ] Tmux with Hyper
- [ ] Tmux configs setup
- [ ] Chezmoi integration
- [ ] Support Linux/Debian
- [ ] DNS Crypt (https://github.com/drduh/config/blob/master/dnscrypt-proxy.toml)
- [ ] Proper configre macup
- [ ] Script to load in bash and zsh
- [ ] Document github setup, blog it as well
- [ ] Dotbot templater plugin
- [ ] Dotbot import private repos plugin

## Awailable Commands

<!-- START makefile-doc -->
```
$ make help
Usage: make [target] [VARIABLE=value]
Targets:
hooks                          Setup pre commit.
validate                       Validate files with pre-commit hooks
vm-up                          Run on Mac. Up
vm-dowm                        Run on Mac. Down
install-local                  Install locally
ignore-dirty                   Ignore dirty commits
install-deps                   Install dependencies
git-module-remove              Remove submodule MODULE=something
brew-install                   Install Brew
```
<!-- END makefile-doc -->

### :memo: Guidelines

 - :memo: Use a succinct title and description.
 - :bug: Bugs & feature requests can be be opened
 - :signal_strength: Support questions are better asked on [Stack Overflow](https://stackoverflow.com/)
 - :blush: Be nice, civil and polite ([as always](http://contributor-covenant.org/version/1/4/)).

## License

Copyright 2019 Ivan Katliarhcuk

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## How to Contribute

Submit a pull request

# Authors

Currently maintained by [Ivan Katliarchuk](https://github.com/ivankatliarchuk) and these [awesome contributors](https://github.com/ivankatliarchuk/dotfiles/graphs/contributors).

[![ForTheBadge uses-git](http://ForTheBadge.com/images/badges/uses-git.svg)](https://GitHub.com/)
