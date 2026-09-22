reload_zshrc(){
  source ~/.zshrc
}
zle -N reload_zshrc

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^B" reload_zshrc
