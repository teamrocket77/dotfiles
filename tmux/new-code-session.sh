#!/usr/bin/env bash
# Fuzzy-pick an immediate subdirectory of ~/code and open it as a new tmux window,
# then ask what to run in it:
#   t : just a terminal
#   n : nvim on the left, empty terminal on the right (vsplit)
#   c : claude on the left, empty terminal on the right (vsplit)
#
# tmux port of kitty's new-code-session.sh. Invoked from tmux.conf as a popup:
# prefix (C-a) then `s`. The popup inherits $TMUX, so the `tmux` commands below
# target the current session; the popup closes when this script exits, dropping
# the client onto the freshly-created window.
set -euo pipefail

# The popup may inherit a minimal PATH — add the usual spots so fzf/nvim resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

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

# Ask what to run — a second fzf stands in for kitty's `ask --type=choices`.
# Each line: "<key>\t<label>"; fzf shows the label, we keep the key.
if ! answer=$(
	printf '%s\t%s\n' \
		t 'just a Terminal' \
		n 'Nvim' \
		c 'Claude' |
		fzf --delimiter='\t' --with-nth='2..' --reverse --prompt="open $name> " \
			--header='enter: choose what to run'
); then
	exit 0
fi
program=${answer%%$'\t'*}
[ -n "$program" ] || exit 0

# open_window <dir> <title> [program]
# Opens a new window in <dir>. With a program, runs it in the window and adds an
# empty terminal to its right via vsplit, then puts focus back on the program.
open_window() {
	local dir=$1 title=$2 prog=${3:-}
	if [ -n "$prog" ]; then
		tmux new-window -c "$dir" -n "$title" "$prog"
		tmux split-window -h -c "$dir"
		tmux select-pane -L
	else
		tmux new-window -c "$dir" -n "$title"
	fi
}

case $program in
	n) open_window "$dir" "$name" nvim ;;
	c) open_window "$dir" "$name" claude ;;
	t) open_window "$dir" "$name" ;;
	*) exit 0 ;;
esac
