#! /usr/bin/env zsh
# Interactive shell init, sourced from ~/.zshrc on non-Nix (work) machines.
# Only the interactive half (shell/rc/*) is loaded here. Env vars, PATH, and
# functions live in shell/env/* and are sourced from ~/.zshenv so they are also
# available to non-interactive shells (nvim :!, system(), scripts). See the
# zshenv.tmpl.sh in this repo for the required ~/.zshenv snippet.
if [[ -d ~/.config/shell/rc ]]; then
    for F in ~/.config/shell/rc/*(.N); do
        if ! source "$F"; then
            echo "Error sourcing: $F"
        fi
    done
fi
export PATH="$HOME/.local/bin:$PATH"
