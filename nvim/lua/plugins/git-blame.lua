-- Inline git blame virtual text for the current line.
vim.pack.add({
	{
		src = "https://github.com/f-person/git-blame.nvim",
		version = "5c536e2d4134d064aa3f41575280bc8a2a0e03d7"
	}
})

-- Update on CursorHold instead of CursorMoved so blame isn't recomputed on every
-- cursor step — cheaper in large projects. Must be set before setup().
vim.g.gitblame_schedule_event = "CursorHold"
vim.g.gitblame_clear_event = "CursorHoldI"

require("gitblame").setup({
	-- Start disabled; toggle on with <leader>gbt. `setup()` writes vim.g from
	-- these opts (opts win over any vim.g.gitblame_* set beforehand), so this is
	-- the single source of truth for the initial state.
	enabled = false,
	message_template = " <author> • <date> • <summary>",
	date_format = "%r (%Y-%m-%d)",
	message_when_not_committed = " Not committed yet",
	highlight_group = "Comment",
	delay = 250,
})

vim.keymap.set("n", "<leader>gbt", vim.cmd.GitBlameToggle, { desc = "Git blame: toggle" })
vim.keymap.set("n", "<leader>gbo", vim.cmd.GitBlameOpenCommitURL, { desc = "Git blame: open commit URL" })
vim.keymap.set("n", "<leader>gbc", vim.cmd.GitBlameCopySHA, { desc = "Git blame: copy SHA" })
