#!/bin/sh
# ≈ tmux prefix+space (next-layout): toggle the current tab between an even
# row (tmux even-horizontal) and an even column (tmux even-vertical). herdr
# has no layout primitive and refuses same-tab pane moves, so each pane is
# bounced through a throwaway tab and re-inserted with a ratio that keeps the
# splits even. Bound from config.toml as a detached shell command (prefix+space).
set -eu

# Detached commands may inherit a minimal PATH — make sure herdr/jq resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

pane="${HERDR_ACTIVE_PANE_ID:?not launched from a herdr keybinding}"
layout=$(herdr pane layout --pane "$pane" | jq '.result.layout')

tab=$(printf '%s' "$layout" | jq -r '.tab_id')

# Rearranging underneath a zoomed pane would be invisible and confusing.
[ "$(printf '%s' "$layout" | jq -r '.zoomed')" = "false" ] || exit 0

# Panes in visual order (top-to-bottom, then left-to-right).
set -- $(printf '%s' "$layout" | jq -r '.panes | sort_by(.rect.y, .rect.x) | .[].pane_id')
n=$#
[ "$n" -ge 2 ] || exit 0

# Toggle: any stacked split -> flatten to a row; already a pure row -> column.
if printf '%s' "$layout" | jq -e '[.splits[].direction] | any(. == "down")' >/dev/null; then
	dir=right
else
	dir=down
fi

prev=$1
shift
i=1
for p in "$@"; do
	# Inserting pane i of n: give the target 1/(n-i+1) of its cell so the
	# finished strip comes out in even 1/n slices without a resize pass.
	ratio=$(awk -v d=$((n - i + 1)) 'BEGIN { printf "%.4f", 1 / d }')
	focus=--no-focus
	[ "$p" = "$pane" ] && focus=--focus
	herdr pane move "$p" --new-tab --no-focus >/dev/null
	herdr pane move "$p" --tab "$tab" --split "$dir" --target-pane "$prev" --ratio "$ratio" "$focus" >/dev/null
	prev=$p
	i=$((i + 1))
done
