return {
	{
		"folke/tokyonight.nvim", config = function()
		end,
	},
	{
	  "catppuccin/nvim",
	  name = "catppuccin",
	  priority = 1000,
	  config = function()
		require("catppuccin").setup({
			transparent_background = true,
			show_end_of_buffer = true,
			background = {
				light = "latte",
			},
			dim_inactive = {
				enabled = true,
				percentage = .30
			},
			integrations = {
				gitsigns = false,
				mini = {
					enabled = false,
				}
			}
		})
		-- setup must be called before loading
		vim.cmd.colorscheme "catppuccin"
	  end,
	}
}
