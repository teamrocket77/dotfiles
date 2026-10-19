#!/bin/sh
# fzf tab finder (≈ tmux choose-window): fuzzy-match on tab number, label, and
# the terminal titles of the tab's panes, then focus the pick. Bound from
# config.toml as a popup (prefix+w, same as tmux). Cancelling the picker is a
# silent no-op.
set -eu

# The popup may inherit a minimal PATH — add the usual spots so fzf/jq resolve
# regardless of how herdr launched it.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

tabs=$(herdr tab list | jq '.result.tabs')
panes=$(herdr pane list | jq '.result.panes')

# One line per tab: hidden tab_id, then "N: label — pane titles". fzf hides the
# id column (--with-nth=2..) but we cut it back out of the pick to focus it.
if ! pick=$(
	jq -n -r --argjson tabs "$tabs" --argjson panes "$panes" '
		$tabs[] | . as $t
		| [$panes[] | select(.tab_id == $t.tab_id) | .terminal_title_stripped] as $titles
		| "\($t.tab_id)\t\($t.number): \($t.label) — \($titles | join(" | "))"
	' | fzf --reverse --prompt='tab> ' --delimiter='\t' --with-nth=2..
); then
	exit 0
fi

[ -n "${pick:-}" ] || exit 0

exec herdr tab focus "$(printf '%s\n' "$pick" | cut -f1)"
