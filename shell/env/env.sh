# Sourced by ~/.zshenv → runs for EVERY zsh: interactive, `zsh -c` (nvim :!,
# system()), scripts, cron. Keep it fast and side-effect-light: env vars, PATH,
# and cheap setup only. Anything interactive or subprocess-heavy (plugins, prompt,
# man/brew/xcrun) belongs in shell/rc/, sourced from .zshrc instead.

# 1. Core Environment
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export GIT_CONFIG_SYSTEM="$XDG_CONFIG_HOME/gitconfig/gitconfig.toml"
export WEZTERM_CONFIG_DIR="$XDG_CONFIG_HOME/wezterm"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# 2. Git Config Rendering
# Render the git config once, when the source exists but the target doesn't.
# Guarded on ruby too, so non-interactive shells/scripts don't error if ruby is
# absent (this file now runs for them as well).
if [[ -d "$XDG_CONFIG_HOME/gitconfig" ]]; then
    if (( $+commands[ruby] )) \
        && [[ -f "$XDG_CONFIG_HOME/gitconfig/render-config.rb" && ! -f "$XDG_CONFIG_HOME/gitconfig/gitconfig" ]]; then
        ruby "$XDG_CONFIG_HOME/gitconfig/render-config.rb"
    fi
fi

# 3. Source personal overrides early
[[ -f ~/personal.sh ]] && source ~/personal.sh

# 4. PATH Management (Defensive style)
# In .zshenv on purpose: non-interactive shells (nvim :!, scripts) must resolve
# the same binaries as interactive ones — otherwise a function found here can't
# find the app it shells out to.
typeset -U path # zsh trick: keep PATH free of duplicate entries automatically

# Add app dirs only if they exist
[[ -d "/Applications/Docker.app/Contents/Resources/bin" ]] && path=("/Applications/Docker.app/Contents/Resources/bin" $path)
[[ -d "/Applications/WezTerm.app/Contents/MacOS" ]] && path=($path "/Applications/WezTerm.app/Contents/MacOS")
[[ -d "/Applications/Pritunl.app/Contents/Resources" ]] && path=($path "/Applications/Pritunl.app/Contents/Resources")
[[ -d "/Applications/OpenVPN Connect.app/Contents/MacOS" ]] && path=($path "/Applications/OpenVPN Connect.app/Contents/MacOS")

# 5. ripgrep config (dotfiles path first, then ~/.config)
RG_CONF="nvim/rg.conf"
if [[ -f "$HOME/dotfiles/$RG_CONF" ]]; then
	export RIPGREP_CONFIG_PATH="$HOME/dotfiles/$RG_CONF"
elif [[ -f "$HOME/.config/$RG_CONF" ]]; then
	export RIPGREP_CONFIG_PATH="$HOME/.config/$RG_CONF"
fi
