vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter.git",
		version = "main",
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter-context.git"
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git",
	}
})

require("nvim-treesitter").install({
	"yaml", "helm", "gotmpl", "hcl", "terraform", "bash", "json", "dockerfile",
})

vim.treesitter.language.register("yaml", { "yaml.gitlab", "yaml.helm" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"yaml", "yaml.gitlab", "yaml.helm", "helm", "gotmpl",
		"hcl", "terraform", "sh", "bash", "json", "dockerfile",
	},
	callback = function() pcall(vim.treesitter.start) end,
})
require("treesitter-context").setup{
	enable = true,
	max_lines = 3,
	trim_scope = 'outer',
}
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v", -- charwise
			["@function.outer"] = "V",  -- linewise
			["@class.outer"] = "<c-v>", -- blockwise
		},
		include_surrounding_whitespace = false,
	},
})
vim.keymap.set({ "x", "o" }, "af", function()
	require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
	require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
	require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
	require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)
-- You can also use captures from other query groups like `locals.scm`
vim.keymap.set({ "x", "o" }, "as", function()
	require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
end)
