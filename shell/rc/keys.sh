reload_zshrc(){
  source ~/.zshrc
}
zle -N reload_zshrc

# zsh-vi-mode (rc/plugins.sh) resets the keymaps when it initializes, so bind
# here, after its init, or the bindings only land in the unused emacs keymap.
zvm_after_init() {
  bindkey -M viins "^[[1;3C" forward-word
  bindkey -M viins "^[[1;3D" backward-word
  bindkey -M viins "^B" reload_zshrc
  bindkey -M vicmd "^B" reload_zshrc
}
