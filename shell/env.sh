# 1. Core Environment
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export GIT_CONFIG_SYSTEM="$XDG_CONFIG_HOME/gitconfig/gitconfig.toml"
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

RG_CONF="nvim/rg.conf"
if [[ -f "$HOME/dotfiles/$RG_CONF" ]]; then
	export RIPGREP_CONFIG_PATH="$HOME/dotfiles/$RG_CONF"
elif [[ -f "$HOME/.config/$RG_CONF" ]]; then
	export RIPGREP_CONFIG_PATH="$HOME/.config/$RG_CONF"
fi

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

# On Nix machines the plugins are managed by home-manager; only self-manage them
# on non-Nix (e.g. work) shells, and only if git is available to clone them.
if [[ -z "$NIX_PROFILES" ]] && (( $+commands[git] )); then
	load_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions.plugin.zsh"
	load_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting.zsh"
fi

if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# Enable colors for man pages
export LESS_TERMCAP_mb=$'\e[1;32m'   # Start blinking (Green)
export LESS_TERMCAP_md=$'\e[1;32m'   # Start bold (Green)
export LESS_TERMCAP_me=$'\e[0m'      # End all mode changes
export LESS_TERMCAP_se=$'\e[0m'      # End standout mode
export LESS_TERMCAP_so=$'\e[01;33m'  # Start standout mode (Yellow background / status bar)
export LESS_TERMCAP_ue=$'\e[0m'      # End underline
export LESS_TERMCAP_us=$'\e[1;4;31m' # Start underline (Underlined Red)
export LESS="-R"
export GROFF_NO_SGR=1
export manroffopt="-c"
export GROFF_NO_SGR=1
export manroffopt="-c"

# weird stuff to handle man pages since  I have a hybrid setup
XCRUN_MAN="$(xcrun --show-sdk-path)/usr/share/man"
BREW_PREFIX="$(brew --prefix)"

if [[ -f "$BREW_PREFIX/bin/zsh" && -f "$BREW_PREFIX/share/zsh/help" || -f "$BREW_PREFIX/share/zsh/helpfiles" ]]; then
	export HELPDIR="$BREW_PREFIX/share/zsh/help"
fi

# not this could also be set via:
#	1: home-manager
#	2: nix-darwin
if [[ -n "$HELPDIR" ]]; then
	autoload -Uz run-help
	autoload -Uz run-help-git
	autoload -Uz run-help-zsh
fi

if [[ -d "$XCRUN_MAN" ]]; then
	export PATH="$XCRUN_MAN:$PATH"
else
fi

alias make-what-is="sudo /usr/libexec/makewhatis $(manpath | tr ':' ' ')"
alias help="run-help"
export FZF_DEFAULT_OPTS="
  --layout=reverse 
  --height=45% 
  --border=rounded 
  --cycle 
  --multi 
  --bind 'ctrl-e:execute(echo {+f} > ~/fzf_selections.log)'
"
