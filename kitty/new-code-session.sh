#!/usr/bin/env bash
# Fuzzy-pick an immediate subdirectory of ~/code and open it as a new tab laid
# out like a workspace: nvim on the left, an empty terminal on the right (vsplit).
# Invoked from kitty.conf as an overlay: winmode (ctrl+a) then `o`.
#
# kitty.conf launches this through `$SHELL -lc`, so the login shell has already
# sourced your normal environment (PATH etc.) — no PATH shim needed here, and
# fzf/nvim/kitten resolve the same way they do at an interactive prompt.
set -euo pipefail

# Talk to kitty via the `kitten @` remote-control client (falls back to `kitty @`).
kitten() { command kitten "$@" 2>/dev/null || command kitty "$@"; }

code_root="$HOME/code"

# Each line: "<basename>\t<fullpath>" — fzf shows only the basename, matches on it.
if ! selection=$(
	find "$code_root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort |
		awk -F/ '{print $NF "\t" $0}' |
		fzf --delimiter='\t' --with-nth=1 --reverse --prompt='code> '
); then
	exit 0
fi

[ -n "${selection:-}" ] || exit 0

name=${selection%%$'\t'*}
dir=${selection#*$'\t'}

# 1. New tab whose sole (original) window runs nvim — this window keeps the left
#    half when we split. Capture its id so we can anchor the split to it.
nvim_win=$(kitten @ launch --type=tab --tab-title "$name" --cwd "$dir" nvim)

# 2. vsplit an empty terminal beside nvim. kitty adds the NEW window in the freed
#    half, so it lands on the right while nvim stays left. --match anchors the
#    split to the nvim window rather than whatever happens to be active.
term_win=$(kitten @ launch --location=vsplit --match "id:${nvim_win}" --cwd "$dir")

# 3. Land in the empty terminal on the right.
kitten @ focus-window --match "id:${term_win}"
