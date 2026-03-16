#! /usr/bin/env zsh
if [[ -d ~/.config/shell ]]; then
    for F in ~/.config/shell/*(.N); do
        if ! source "$F"; then
            echo "Error sourcing: $F"
        fi
    done
fi
