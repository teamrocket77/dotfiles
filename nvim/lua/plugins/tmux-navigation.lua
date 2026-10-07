-- Seamless pane navigation between nvim splits and tmux panes with <C-h/j/k/l>.
-- The matching tmux side lives in tmux/tmux.conf (is_vim detection + root C-hjkl).
vim.pack.add({
	{
		src = "https://github.com/alexghergh/nvim-tmux-navigation",
		version = "4898c98702954439233fdaf764c39636681e2861"
	}
})

-- setup() must be called at least once (even empty) or the plugin is inert.
require("nvim-tmux-navigation").setup({
	disable_when_zoomed = true,
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
		last_active = "<C-\\>",
		next = "<C-Space>",
	},
})
