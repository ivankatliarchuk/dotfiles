# mise-related Make targets, included by the root Makefile.
# Grouping them here keeps the root Makefile focused and lets this file travel
# with the rest of tools/mise/.

macos-defaults-status: ## Show drift between mise/conf.d/macos.toml and current macOS defaults
	@mise bootstrap macos defaults status

macos-defaults-apply: ## Apply macOS defaults from mise/conf.d/macos.toml (writes real system prefs)
	@mise bootstrap macos defaults apply

mise-install: ## Install tools from the global mise config (node, go, ...)
	@mise install

mise-lock-global: ## Regenerate the global mise.lock (tools/mise/mise.lock)
	@mise lock --global

mise-status: ## List configured mise tools and resolved versions
	@mise ls --current

mise-doctor: ## Full mise diagnostics (PATH, shims, plugins, cache)
	@mise doctor

mise-self-update: ## Update mise itself to the latest release
	@mise self-update

mise-upgrade-dry-run: ## Preview tool upgrades without applying them
	@mise upgrade --dry-run

mise-upgrade-bump: ## Bump pinned tool versions to latest and upgrade
	@mise upgrade --bump

mise-dotfiles-status: ## Show dotfiles drift against mise/conf.d fragments
	@mise bootstrap dotfiles status

mise-dotfiles-apply: ## Apply dotfiles symlinks (raw, no protected-targets filter)
	@mise bootstrap dotfiles apply --force --yes

.PHONY: macos-defaults-status macos-defaults-apply mise-install mise-lock-global mise-status mise-doctor mise-self-update mise-upgrade-dry-run mise-upgrade-bump mise-dotfiles-status mise-dotfiles-apply
