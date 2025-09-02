export GIT_CONFIG_SYSTEM="$HOME/.config/gitconfig/gitconfig.toml"
export GPG_TTY=$(tty)
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm/"

if [ -f  ~/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh ]; then
	source ~/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
fi

if [ -f  ~/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
	source ~/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if (( $+commands[direnv] )); then
	eval "$(direnv hook zsh)"
else
	echo "Direnv does not exist"
fi
if (( $+commands[zoxide] )); then
	eval "$(zoxide init zsh)"
else
	echo "zoxide does not exist"
 fi


