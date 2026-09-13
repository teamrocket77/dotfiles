-- Markdown editing (tadmccorkle/markdown.nvim). Complements markview.nvim's
-- rendering with actual edit ops: checkbox toggle, table of contents, list
-- continuation, and emphasis/link operators. Treesitter-based; the markdown
-- parsers are installed in plugins/treesitter.lua.
--
-- The plugin attaches only to markdown buffers, so on_attach keymaps are
-- inherently buffer-local. Commands available in markdown buffers:
--   :MDTaskToggle          toggle checkbox ([ ] <-> [x])
--   :MDInsertToc [lvl]     insert a table of contents at the cursor
--   :MDToc / :MDTocAll     TOC into the location list
vim.pack.add({
	{ src = "https://github.com/tadmccorkle/markdown.nvim" },
})

require("markdown").setup({
	on_attach = function(bufnr)
		local map = vim.keymap.set
		-- <Leader><Space> toggles the task-list checkbox: current line in normal
		-- mode, the whole selection in visual. Visual uses ':' (not <Cmd>) so the
		-- range is passed to the command.
		map("n", "<leader><Space>", "<Cmd>MDTaskToggle<CR>", { buffer = bufnr, desc = "Toggle markdown checkbox" })
		map("x", "<leader><Space>", ":MDTaskToggle<CR>", { buffer = bufnr, desc = "Toggle markdown checkbox" })
	end,
})
