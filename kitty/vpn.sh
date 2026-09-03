#!/usr/bin/env bash
# Interactive Pritunl VPN selector (single tunnel). Lists pritunl-client profiles
# with their connection state, then toggles the picked one: connecting a profile
# first disconnects any others, and picking the connected profile disconnects it.
# Invoked from kitty.conf as an overlay (winmode → v) and runnable directly as
# `vpn` (see shell/functions.sh).
set -euo pipefail

# The overlay may inherit a minimal PATH — add the usual spots plus the Pritunl
# app bundle so fzf/jq and the client resolve regardless of how kitty started.
export PATH="/opt/homebrew/bin:/usr/local/bin:/Applications/Pritunl.app/Contents/Resources:$PATH"

cli="$(command -v pritunl-client || true)"
[ -x "$cli" ] || cli="/Applications/Pritunl.app/Contents/Resources/pritunl-client"
if [ ! -x "$cli" ]; then
	echo "vpn: pritunl-client not found"; sleep 1.5; exit 1
fi

# Each line: "<id>\t<connected>\t<marker> <name>" — fzf shows only column 3+ and
# matches on the name; ● marks a connected profile, ○ a disconnected one.
if ! selection=$(
	"$cli" list -j |
		jq -r '.[] | [.id, (.connected|tostring),
			((if .connected then "●" else "○" end) + " " + .name)] | @tsv' |
		fzf --delimiter='\t' --with-nth='3..' --reverse --prompt='vpn> ' \
			--header='enter: toggle (single tunnel)'
); then
	exit 0
fi

[ -n "${selection:-}" ] || exit 0

id=$(printf '%s' "$selection" | cut -f1)
conn=$(printf '%s' "$selection" | cut -f2)
name=$(printf '%s' "$selection" | cut -f3-)
name=${name#* }   # drop the ●/○ marker for the message

if [ "$conn" = "true" ]; then
	echo "Disconnecting: $name"
	"$cli" stop "$id" >/dev/null 2>&1 || true
else
	# single-tunnel: stop every currently-connected profile before connecting.
	"$cli" list -j | jq -r '.[] | select(.connected) | .id' | while IFS= read -r other; do
		[ -n "$other" ] && "$cli" stop "$other" >/dev/null 2>&1 || true
	done
	echo "Connecting: $name"
	"$cli" start "$id" || true
fi
sleep 1
