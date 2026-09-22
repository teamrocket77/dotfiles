#!/usr/bin/env bash
# Interactive OpenVPN Connect profile switcher (single tunnel). OpenVPN Connect's
# own app drives the tunnel via two undocumented CLI verbs — `--list-profiles`
# (JSON of imported profiles) and `--connect-shortcut=<id>` — so no sudo and no
# community openvpn binary are needed; the app's privileged helper does the work
# and its UI collects the Okta passcode/push.
#
# Picks a profile with fzf, disconnects whatever is currently up, then connects
# the choice. A synthetic "⏻ disconnect" entry at the top just tears down the
# current tunnel.
#
# Invoked from kitty.conf as an overlay (winmode -> shift+v) and runnable directly
# as `vpn-ovpn` (see shell/functions.sh). Companion to vpn.sh (Pritunl, winmode v).
set -euo pipefail

# The overlay may inherit a minimal PATH — add the usual spots plus the OpenVPN
# Connect bundle so fzf/jq and the app binary resolve regardless of how kitty
# started.
export PATH="/opt/homebrew/bin:/usr/local/bin:/Applications/OpenVPN Connect.app/Contents/MacOS:$PATH"

app="/Applications/OpenVPN Connect.app/Contents/MacOS/OpenVPN Connect"

die() { echo "vpn-ovpn: $*" >&2; sleep 2; exit 1; }

[ -x "$app" ] || die "OpenVPN Connect not found (import your profiles into the app first)"
command -v jq  >/dev/null || die "jq not found — run: brew install jq"
command -v fzf >/dev/null || die "fzf not found — run: brew install fzf"

DISCONNECT=$'\x00disconnect'   # sentinel id for the synthetic teardown entry

# Each line: "<id>\t<name>  (<host>)" — fzf shows/searches column 2+, the id in
# column 1 is what we pass to --connect-shortcut. A leading teardown entry lets
# you disconnect without connecting anything.
if ! selection=$(
	{
		printf '%s\t%s\n' "$DISCONNECT" "⏻ disconnect (current tunnel)"
		"$app" --list-profiles 2>/dev/null |
			jq -r '.[] | [ .id, (.name + "  (" + .host + ")") ] | @tsv'
	} |
		fzf --delimiter='\t' --with-nth='2..' --reverse --prompt='ovpn> ' \
			--header='enter: switch (single tunnel · disconnects current first)'
); then
	exit 0
fi

[ -n "${selection:-}" ] || exit 0

id=$(printf '%s' "$selection" | cut -f1)
name=$(printf '%s' "$selection" | cut -f2-)
name=${name%%  (*}   # drop the "  (host)" suffix for the message

# Always drop the current tunnel first (single tunnel).
echo "Disconnecting current tunnel…"
"$app" --disconnect >/dev/null 2>&1 || true

if [ "$id" = "$DISCONNECT" ]; then
	echo "Disconnected."
	sleep 1
	exit 0
fi

sleep 1
echo "Connecting: $name"
echo "(OpenVPN Connect will prompt for the Okta passcode / push in its own window)"
"$app" --connect-shortcut="$id" >/dev/null 2>&1 || die "connect failed for: $name"
sleep 1
