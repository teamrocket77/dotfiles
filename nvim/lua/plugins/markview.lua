vim.pack.add({
	{ src = "https://github.com/OXY2DEV/markview.nvim", version = "3537eb2a9251cad5d7718253768f3772c62233fc" },
})

vim.schedule(function()
	require("markview").setup({})
end)
