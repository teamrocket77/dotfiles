vim.pack.add({
	{
src = "https://github.com/stevearc/conform.nvim.git",
version = "3543d000dafbc41cc7761d860cfdb24e82154f75",
	}
})

require("conform").setup({
	formatters_by_ft = {
		yaml = { "yamlfmt" },
		["yaml.gitlab"] = { "yamlfmt" },
		["yaml.helm"] = { "yamlfmt" },
	},
})

vim.api.nvim_create_user_command("Format", function(args)
	local range
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = { start = { args.line1, 0 }, ["end"] = { args.line2, end_line:len() } }
	end
	require("conform").format({ range = range, lsp_format = "fallback" })
end, { range = true })

vim.keymap.set({ "n", "v" }, "<leader>fm", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format buffer/selection (conform)" })
