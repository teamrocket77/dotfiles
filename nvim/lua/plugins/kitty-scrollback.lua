-- Browse the kitty scrollback buffer / last command output in Neovim.
-- kitty calls the plugin's python kitten directly (see action_alias in
-- kitty.conf); the kitten launches this nvim config, which loads the plugin
-- and hands the window over. Replaces the old hand-rolled `scrollback_pager`.
vim.pack.add({
  {
    src = "https://github.com/mikesmithgh/kitty-scrollback.nvim",
  },
})

require("kitty-scrollback").setup()
