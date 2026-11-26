#!/bin/sh
# fzf tab finder (≈ tmux choose-window): fuzzy-match on the tab label only, but
# show each tab's workspace, number and pane titles alongside it, then focus
# the pick. Bound from config.toml as a popup (prefix+w, same as tmux).
# Cancelling the picker is a silent no-op.
set -eu

# The popup may inherit a minimal PATH — add the usual spots so fzf/jq resolve
# regardless of how herdr launched it.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

workspaces=$(herdr workspace list | jq '.result.workspaces')
tabs=$(herdr tab list | jq '.result.tabs')
panes=$(herdr pane list | jq '.result.panes')

# One line per tab, tab-delimited: hidden tab_id, workspace (padded so the
# columns line up), "N:", label, pane titles. fzf hides the id column
# (--with-nth=2..) and searches only the label (--nth=3, counted after
# --with-nth); we cut the id back out of the pick to focus it.
if ! pick=$(
	jq -n -r --argjson ws "$workspaces" --argjson tabs "$tabs" --argjson panes "$panes" '
		($ws | map({(.workspace_id): .label}) | add) as $wsname
		| ([$ws[].label | length] | max) as $w
		| $tabs[] | . as $t
		| ($wsname[$t.workspace_id] // $t.workspace_id) as $name
		| [$panes[] | select(.tab_id == $t.tab_id) | .terminal_title_stripped] as $titles
		| [$t.tab_id,
		   $name + (" " * ($w - ($name | length))),
		   "\($t.number):",
		   $t.label,
		   "— \($titles | join(" | "))"]
		| join("\t")
	' | fzf --reverse --prompt='tab> ' --delimiter='\t' --with-nth=2.. --nth=3
); then
	exit 0
fi

[ -n "${pick:-}" ] || exit 0

exec herdr tab focus "$(printf '%s\n' "$pick" | cut -f1)"
