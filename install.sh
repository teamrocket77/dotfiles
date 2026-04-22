# /usr/env /usr/bin/bash
set -euxo pipefail

DOTFILES="$HOME/dotfiles"
if [ -d "$DOTFILES" ]; then
	mkdir -p "$DOTFILES"
	git clone git@github.com:teamrocket77/dotfiles.git "$DOTFILES"
fi
