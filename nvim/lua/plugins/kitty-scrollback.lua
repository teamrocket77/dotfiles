-- Browse the kitty scrollback buffer / last command output in Neovim.
-- kitty calls the plugin's python kitten directly (see action_alias in
-- kitty.conf); the kitten launches this nvim config, which loads the plugin
-- and hands the window over. Replaces the old hand-rolled `scrollback_pager`.
--
-- In scrollback ("pure") mode init.lua early-returns and loads ONLY this file,
-- so none of the normal editor settings apply here. Re-apply the few we want.
vim.pack.add({
  {
    src = "https://github.com/mikesmithgh/kitty-scrollback.nvim",
  },
})

-- Set before setup() so the plugin's <leader> mappings resolve to <Space>.
vim.g.mapleader = " "

-- setup() is keyed by config name; the positional [1] entry is merged as global
-- opts into every config (builtins included). The plugin force-sets
-- cursorline=false on launch, so re-enable current-row + search highlight from
-- after_ready, which fires once the scrollback buffer is ready.
require("kitty-scrollback").setup({
  {
    callbacks = {
      after_ready = function()
        vim.o.hlsearch = true
        vim.o.cursorline = true
      end,
    },
  },
})
