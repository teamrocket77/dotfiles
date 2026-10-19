#!/bin/sh
# fzf project picker over ~/code: pick a directory and open it as a new herdr
# tab (labeled with the project name, focused). Bound from config.toml as a
# popup (prefix+shift+s). Cancelling the picker is a silent no-op.
set -eu

# The popup may inherit a minimal PATH — add the usual spots so fzf resolves
# regardless of how herdr launched it.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

root="$HOME/code"
[ -d "$root" ] || exit 0

# List immediate subdirectories of ~/code by name; fzf previews each with a
# plain `ls` of its contents.
if ! pick=$(
	find "$root" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; |
		sort |
		fzf --reverse --prompt='code> ' \
			--preview="ls -1p \"$root\"/{}"
); then
	exit 0
fi

[ -n "${pick:-}" ] || exit 0

exec herdr tab create --cwd "$root/$pick" --label "$pick" --focus
