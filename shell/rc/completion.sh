# Interactive completion init. Sorts before plugins.sh (c < p), so it runs BEFORE
# anything that calls `compdef` — zoxide here, plus pyenv/mise later in .zshrc.
# Without this, `compdef` is undefined and those inits return non-zero (that was
# the "Error sourcing: plugins.sh" on non-Nix machines).
#
# On Nix, home-manager's `enableCompletion = true` already runs compinit, so the
# guard below skips this to avoid doing the work twice.
if (( ! $+functions[compdef] )); then
	# Static completion dirs must be on fpath BEFORE compinit scans it.
	(( $+commands[brew] )) && fpath+=("$(brew --prefix)/share/zsh/site-functions")

	autoload -Uz compinit
	# Rebuild ("purge") the dump at most once a day: if ~/.zcompdump is missing or
	# older than 24h, run a full compinit that regenerates it; otherwise load the
	# cached dump fast (-C skips the security audit). Delete ~/.zcompdump* by hand
	# to force an immediate rebuild.
	if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
		compinit
	else
		compinit -C
	fi
fi
