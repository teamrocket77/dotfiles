#!/bin/sh
# Turn passthrough mode off via kitty remote control.
#
# passthrough mode (see kitty.conf) forwards every key to the program, so the
# usual ctrl+shift+f12 exit can't be typed if something grabs the keys. This
# pops the keyboard mode out-of-band instead.
#
# Uses $KITTY_LISTEN_ON when run inside kitty; otherwise sweeps every
# /tmp/kitty-<pid> socket (listen_on unix:/tmp/kitty appends the PID).

set -eu

pop() {
	kitten @ --to "$1" action pop_keyboard_mode
}

if [ -n "${KITTY_LISTEN_ON:-}" ]; then
	pop "$KITTY_LISTEN_ON"
	exit 0
fi

found=0
for sock in /tmp/kitty-*; do
	[ -S "$sock" ] || continue
	found=1
	pop "unix:$sock" || echo "warn: failed on $sock" >&2
done

if [ "$found" -eq 0 ]; then
	echo "no kitty socket found (is 'listen_on unix:/tmp/kitty' set and kitty running?)" >&2
	exit 1
fi
