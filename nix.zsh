# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


if [[ -d "$HOME/dotfiles/shell" ]]; then
    for F in ~/dotfiles/shell/*(.N); do
        if ! source "$F"; then
            echo "Error sourcing: $F"
        fi
    done
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/dotfiles/.p10k.zsh" ]] || source "$HOME/dotfiles/.p10k.zsh"

(( ! ${+functions[p10k]} )) || p10k finalize
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
export POWERLEVEL_SET=true
