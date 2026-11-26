-- fugitive: :Git/:G status, blame, log, etc. Loaded AFTER plugins.mini on
-- purpose — mini.git also defines a :Git command, and whichever loads last
-- wins; we want fugitive's. mini.git stays for the statusline's git section.
vim.pack.add({
	{
		src = "https://github.com/tpope/vim-fugitive",
		version = "3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0"
	}
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Fugitive: git status" })
vim.keymap.set("n", "<leader>gb", function() vim.cmd.Git("blame") end, { desc = "Fugitive: git blame" })
