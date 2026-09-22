# Interactive-only: plugin manager + shell integrations. Sourced from .zshrc via
# work-init.sh (work) / nix.zsh (Nix). Do NOT source from .zshenv — plugins like
# zsh-vi-mode and zsh-syntax-highlighting misbehave in non-interactive shells and
# would slow down every `zsh -c`/script.

# Self-healing plugin manager: clone on first use, then source.
ZSH_PLUGIN_DIR="$HOME/zsh"
mkdir -p "$ZSH_PLUGIN_DIR"

load_plugin() {
    local name=$1
    local repo=$2
    local file=$3
    if [[ ! -d "$ZSH_PLUGIN_DIR/$name" ]]; then
        echo "Installing $name..."
        git clone --depth 1 "$repo" "$ZSH_PLUGIN_DIR/$name"
    fi
    source "$ZSH_PLUGIN_DIR/$name/$file"
}

# On Nix machines the plugins are managed by home-manager; only self-manage them
# on non-Nix (e.g. work) shells, and only if git is available to clone them.
if [[ -z "$NIX_PROFILES" ]] && (( $+commands[git] )); then
	load_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions.plugin.zsh"
	load_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting.zsh"
fi

# zsh-vi-mode must be sourced last so it can override key bindings set by the
# plugins above. Not managed by home-manager, so self-manage it on every machine.
if (( $+commands[git] )); then
	load_plugin "zsh-vi-mode" "https://github.com/jeffreytse/zsh-vi-mode.git" "zsh-vi-mode.plugin.zsh"
fi

if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# Defensive: rc/completion.sh runs compinit before this file, so `compdef` exists
# and zoxide's init returns 0. Keep this `true` anyway so any future integration
# above that leaves a non-zero $? can't make work-init.sh/nix.zsh misreport this
# file as "Error sourcing".
true
