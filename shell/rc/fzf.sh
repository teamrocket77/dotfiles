# Interactive-only: default fzf options.
export FZF_DEFAULT_OPTS="
  --layout=reverse
  --height=45%
  --border=rounded
  --cycle
  --multi
  --bind 'ctrl-e:execute(echo {+f} > ~/fzf_selections.log)'
"
