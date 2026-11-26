#!/bin/sh
# fzf picker over the full zoxide directory list (`zoxide query --list`): pick
# a directory and open it as a new herdr tab (labeled with its basename,
# focused). Bound from config.toml as a popup (prefix+shift+s). Cancelling the
# picker is a silent no-op.
set -eu

# The popup may inherit a minimal PATH — add the usual spots so fzf and zoxide
# resolve regardless of how herdr launched it.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! pick=$(
	zoxide query --list |
		fzf --reverse --prompt='zoxide> ' \
			--preview='ls -1p {}'
); then
	exit 0
fi

[ -n "${pick:-}" ] || exit 0
[ -d "$pick" ] || exit 0

# Bump the pick's zoxide score so the ranking reflects popup usage too.
zoxide add "$pick"

exec herdr tab create --cwd "$pick" --label "$(basename "$pick")" --focus
