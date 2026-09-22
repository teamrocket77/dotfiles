# Interactive-only: man/less colorization + zsh run-help. This file forks
# `brew --prefix` and `xcrun` at startup, so it stays out of .zshenv to keep
# non-interactive shells (nvim :!, scripts) fast.

# Colorize man pages via LESS termcap overrides.
export LESS_TERMCAP_mb=$'\e[1;32m'   # Start blinking (Green)
export LESS_TERMCAP_md=$'\e[1;32m'   # Start bold (Green)
export LESS_TERMCAP_me=$'\e[0m'      # End all mode changes
export LESS_TERMCAP_se=$'\e[0m'      # End standout mode
export LESS_TERMCAP_so=$'\e[01;33m'  # Start standout mode (Yellow status bar)
export LESS_TERMCAP_ue=$'\e[0m'      # End underline
export LESS_TERMCAP_us=$'\e[1;4;31m' # Start underline (Underlined Red)
export LESS="-R"
export GROFF_NO_SGR=1
export manroffopt="-c"

# Hybrid setup: prefer the SDK man dir and Homebrew's zsh help.
XCRUN_MAN="$(xcrun --show-sdk-path 2>/dev/null)/usr/share/man"
BREW_PREFIX="$(brew --prefix 2>/dev/null)"

if [[ -f "$BREW_PREFIX/bin/zsh" && -f "$BREW_PREFIX/share/zsh/help" || -f "$BREW_PREFIX/share/zsh/helpfiles" ]]; then
	export HELPDIR="$BREW_PREFIX/share/zsh/help"
fi

# Could also be set via home-manager / nix-darwin.
if [[ -n "$HELPDIR" ]]; then
	autoload -Uz run-help
	autoload -Uz run-help-git
	autoload -Uz run-help-zsh
fi

if [[ -d "$XCRUN_MAN" ]]; then
	export PATH="$XCRUN_MAN:$PATH"
fi

alias make-what-is="sudo /usr/libexec/makewhatis $(manpath | tr ':' ' ')"
alias help="run-help"
