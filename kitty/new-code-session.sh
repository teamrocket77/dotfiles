#!/usr/bin/env bash
# Fuzzy-pick an immediate subdirectory of ~/code and open it as a new tab, then
# ask what to run in it:
#   <Enter> / t : just a terminal
#   n           : nvim on the left, empty terminal on the right (vsplit)
#   c           : claude on the left, empty terminal on the right (vsplit)
#
# Invoked from kitty.conf as an overlay: winmode (ctrl+a) then `s`.
#
# kitty.conf launches this through `$SHELL -lc`, so the login shell has already
# sourced your normal environment (PATH etc.) — no PATH shim needed here, and
# fzf/nvim/kitten/jq resolve the same way they do at an interactive prompt.
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
[ -n "$selection" ] || exit 0

name=${selection%%$'\t'*}
dir=${selection#*$'\t'}

# Ask what to run. `ask --type=choices` prints a JSON object to stdout, e.g.
# {"items": [], "response": "n"} — <Enter> yields --default, Esc yields "".
if ! answer=$(
	kitty +kitten ask \
		--type=choices \
		--title="Open $name" \
		--default=t \
		--choice="t:just a Terminal" \
		--choice="n;green:Nvim" \
		--choice="c;magenta:Claude"
); then
	exit 0
fi
program=$(printf '%s' "$answer" | jq -r '.response // empty')
[ -n "$program" ] || exit 0

# open_app <dir> <title> [program]
# Opens a new tab in <dir>. With a program, runs it in the tab and adds an empty
# terminal to its right via vsplit, then puts focus back on the program window.
open_app() {
	local dir=$1 title=$2 program=${3:-}
	local app_win
	if [ -n "$program" ]; then
		app_win=$(kitten @ launch --type=tab --tab-title "$title" --cwd "$dir" "$program")
		kitten @ launch --location=vsplit --next-to "id:${app_win}" --cwd "$dir" >/dev/null
		kitten @ focus-window --match "id:${app_win}"
	else
		kitten @ launch --type=tab --tab-title "$title" --cwd "$dir" >/dev/null
	fi
}

case $program in
	n) open_app "$dir" "$name" nvim ;;
	c) open_app "$dir" "$name" claude ;;
	t) open_app "$dir" "$name" ;;
	*) exit 0 ;;
esac
