-- Seamless pane navigation between nvim splits and *herdr* panes with <C-h/j/k/l>
-- (bojackduy/nvim-herdr-navigation). Only active inside herdr ($HERDR_PANE_ID set);
-- outside herdr, plugins/tmux-navigation.lua owns the same chords. The matching
-- herdr side is the herdr-vim-navigator plugin plus the ctrl+h/j/k/l plugin_action
-- binds in ~/.config/herdr/config.toml.
if vim.env.HERDR_PANE_ID == nil then
	return
end

vim.pack.add({
	{
		src = "https://github.com/bojackduy/nvim-herdr-navigation",
		version = "7798a2f027465698cb1a51695327e138319f61f3",
	},
})

-- The Lua plugin lives in a subdirectory of the repo (the repo also ships the
-- herdr-side plugin), so the repo root vim.pack puts on the rtp isn't enough.
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-herdr-navigation/nvim-herdr-navigation")

require("herdr-navigation").setup({
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
	},
})
