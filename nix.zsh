#! /usr/env /bin/zsh

if [[ -d "$HOME/dotfiles/shell" ]]; then
    for F in ~/dotfiles/shell/*(.N); do
        if ! source "$F"; then
            echo "Error sourcing: $F"
        fi
    done
fi

export PATH="$HOME/.local/bin:$PATH"
