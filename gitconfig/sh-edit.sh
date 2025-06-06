# must be at the top
export GPG_TTY=$(tty)

# can be anywhere
export NAME=""
export EMAIL=""
# export SIGNINGKEY=""
if [ ! -f "$HOME/.config/gitconfig/gitconfig" ]; then
	ruby "$HOME/.config/gitconfig/render-config.rb"
fi
export GIT_CONFIG_SYSTEM="$HOME/.config/gitconfig/gitconfig"

