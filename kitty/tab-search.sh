#!/usr/bin/env bash
# Fuzzy-search kitty tab titles across all OS windows and focus the chosen tab.
# Invoked from kitty.conf as an overlay: winmode (ctrl+a) then `w`.
set -euo pipefail

# The overlay is launched via `sh -c`, which inherits only a minimal PATH — so
# kitty/kitten, fzf (homebrew) and jq may not be found. Add the usual spots plus
# the kitty.app bundle so remote control works regardless of how kitty started.
export PATH="/opt/homebrew/bin:/usr/local/bin:/Applications/kitty.app/Contents/MacOS:$PATH"

# Talk to kitty via the `kitten @` remote-control client (falls back to `kitty @`).
kitten() { command kitten "$@" 2>/dev/null || command kitty "$@"; }

# Each line: "<tab-id>\t<title>" — fzf shows only the title, matches on it.
if ! selection=$(
	kitten @ ls |
		jq -r '.[].tabs[] | "\(.id)\t\(.title)"' |
		fzf --delimiter='\t' --with-nth='2..' --reverse --prompt='tab> '
); then
	exit 0
fi

[ -n "${selection:-}" ] || exit 0

tab_id=${selection%%$'\t'*}
kitten @ focus-tab --match "id:${tab_id}"
