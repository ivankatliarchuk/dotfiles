# Tools installed

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Mixed](#mixed)
- [Git](#git)
- [DNS crypt](#dns-crypt)
- [DNS Dnsmasq](#dns-dnsmasq)
- [Brew](#brew)
  - [Commands](#commands)
- [Wget](#wget)
- [Curl](#curl)
- [Security](#security)
  - [Tools](#tools)
- [Python](#python)
- [OS](#os)
- [Dotfiles](#dotfiles)
- [GPG Setup](#gpg-setup)
- [ZSH](#zsh)
- [NVM](#nvm)
  - [Debug ZSH](#debug-zsh)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Mixed

- [DotBot](https://github.com/anishathalye/dotbot/wiki)
- [Chezmoi Quick Start](https://www.chezmoi.io/docs/quick-start/)

- [Github Hub](https://hub.github.com/)

- [iTerm](https://sourabhbajaj.com/mac-setup/iTerm/)
- [Starship](https://starship.rs/)
- [Hyper](https://github.com/vercel/hyper)
- [Hyper Blog](https://www.robertcooper.me/elegant-development-experience-with-zsh-and-hyper-terminal)

- [Fasd](https://github.com/clvv/fasd)
- [Z](https://github.com/rupa/z)

- [Prezto](https://github.com/sorin-ionescu/prezto)

- [Ybikey Guide](https://github.com/drduh/YubiKey-Guide)
- [NVMRC](https://github.com/nvm-sh/nvm#nvmrc)

## Git

- [GitUp](https://github.com/git-up/GitUp)

## DNS crypt

- [Dns crypt proxy](https://github.com/drduh/config/blob/master/dnscrypt-proxy.toml)

## DNS Dnsmasq

- [Docs](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)
- [Configure v1](https://passingcuriosity.com/2013/dnsmasq-dev-osx/)
- [Configure v2](https://www.stevenrombauts.be/2018/01/use-dnsmasq-instead-of-etc-hosts/)
- [Config Example](https://github.com/dnsmasq/dnsmasq/blob/master/dnsmasq.conf.example)

## Brew

- [Bundle](https://github.com/Homebrew/homebrew-bundle)
- [WhaleBrew](https://github.com/whalebrew/whalebrew)
- [MackUP](https://github.com/lra/mackup)
- [Prezto Brew](https://github.com/sorin-ionescu/prezto/tree/master/modules/homebrew)

### Commands

```bash

brew shellenv

```

## Wget

- [Configuration Options](https://www.gnu.org/software/wget/manual/html_node/Sample-Wgetrc.html)

## Curl

- [Configuration Options](https://ec.haxx.se/cmdline/cmdline-configfile)

## Security

- [MacOs security guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

### Tools

- [macOS: mOSL](https://github.com/0xmachos/mOSL)
- [macOS: Stronghold](https://github.com/alichtman/stronghold)

## Python

- [PyEnv](https://realpython.com/intro-to-pyenv)
- [Pyenv Work with](https://anil.io/blog/python/pyenv/using-pyenv-to-install-multiple-python-versions-tox/)

## OS

- [MacUp: application settings](https://github.com/lra/mackup)

## Dotfiles

- [Dotbot examples](https://github.com/anishathalye/dotbot/wiki/Users)
- [Macos dotfiles](https://github.com/mathiasbynens/dotfiles/blob/main/.macos)
- [Macos dotfiles](https://github.com/BarryMode/macos-prime/blob/master/dotfiles/.macos)
- [Macos dotfiles](https://github.com/powerline/fonts)

## GPG Setup

- [GnuPG auth](https://incenp.org/notes/2015/gnupg-for-ssh-authentication.html)
- [GpG Debian](https://gregrs-uk.github.io/2018-08-06/gpg-key-ssh-mac-debian/)
- [GpG Flow](https://gist.github.com/bcomnes/647477a3a143774069755d672cb395ca)
- [Gistst](https://gist.github.com/bmhatfield/cc21ec0a3a2df963bffa3c1f884b676b)

## ZSH

- [Multiple ZSH profiles](https://www.donielsmith.com/blog/2020-04-12-multiple-zsh-config-in-iterm)
- [What should go in .zshrc](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout)

## NVM

- [NVM](https://github.com/nvm-sh/nvm)
- [NVM: speed up](https://github.com/wzrdtales/nvm-ng)

### Debug ZSH

```sh

$ time zsh -i -c "print -n"
> zsh -i -c "print -n"  1.33s user 0.91s system 103% cpu 2.161 total
> zsh -i -c "print -n"  1.40s user 0.94s system 111% cpu 2.089 total
> zsh -i -c "print -n"  0.92s user 0.69s system 109% cpu 1.476 total

$ time starship prompt
starship prompt  0.04s user 0.04s system 170% cpu 0.044 tota

$ time zsh -i -c exit
> zsh -i -c exit  1.01s user 0.66s system 94% cpu 1.780 total

$ zsh -xv

$ time source ~/.nvm/nvm.sh --no-use

$ do /usr/bin/time bash -i -c exit; done

$ zsh -xv 2>&1 | ts -i "%.s" > zsh_startup.log
$ sort --field-separator=' ' -r -k1 zsh_startup.log> sorted.log

```

```sh

$ source ~/.bashrc

$ echo ${precmd_functions[@]}
> _direnv_hook _terminal-set-titles-with-path _zsh_autosuggest_start _zsh_highlight_main__precmd_hook _z_precmd starship_precmd
> _direnv_hook _terminal-set-titles-with-path _zsh_autosuggest_start _zsh_highlight_main__precmd_hook _z_precmd starship_precmd

$ echo ${preexec_functions[@]}
> _terminal-set-titles-with-command _fasd_preexec _zsh_highlight_preexec_hook starship_preexec starship_preexec starship_preexec starship_preexec
> _terminal-set-titles-with-command _fasd_preexec _zsh_highlight_preexec_hook starship_preexec

```
