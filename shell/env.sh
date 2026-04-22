# 1. Core Environment
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export GIT_CONFIG_SYSTEM="$XDG_CONFIG_HOME/gitconfig/gitconfig.toml"
export GPG_TTY=$(tty)
export WEZTERM_CONFIG_DIR="$XDG_CONFIG_HOME/wezterm"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# 2. Git Config Rendering
if [[ -d "$XDG_CONFIG_HOME/gitconfig" ]]; then
    # Improved check: if the source exists but the target doesn't, run ruby
    if [[ -f "$XDG_CONFIG_HOME/gitconfig/render-config.rb" && ! -f "$XDG_CONFIG_HOME/gitconfig/gitconfig" ]]; then
        ruby "$XDG_CONFIG_HOME/gitconfig/render-config.rb"
    fi
fi

# 3. Source personal overrides early
[[ -f ~/personal.sh ]] && source ~/personal.sh

# 4. PATH Management (Defensive style)
typeset -U path # This Zsh trick prevents duplicate entries in PATH automatically

# Add Docker and Wezterm only if they exist
[[ -d "/Applications/Docker.app/Contents/Resources/bin" ]] && path=("/Applications/Docker.app/Contents/Resources/bin" $path)
[[ -d "/Applications/WezTerm.app/Contents/MacOS" ]] && path=($path "/Applications/WezTerm.app/Contents/MacOS")

# 5. Plugin Manager (Self-healing)
ZSH_PLUGIN_DIR="$HOME/zsh"
mkdir -p "$ZSH_PLUGIN_DIR"

# Helper function to load/clone plugins
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

load_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions.plugin.zsh"
load_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting.zsh"
load_plugin "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "powerlevel10k.zsh-theme"

if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi
true
