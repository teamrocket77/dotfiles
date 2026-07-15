vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim"},
	{ src = "https://github.com/folke/noice.nvim", version = "cf758e9df66451889aab56613a21b8673f045ec2" },
	{ src = "https://github.com/folke/flash.nvim", version = "ec0bf2842189f65f60fd40bf3557cac1029cc932" },
	{ src = "https://github.com/folke/lazydev.nvim", version = "01bc2aacd51cf9021eb19d048e70ce3dd09f7f93" },
})

vim.schedule(function()
  require("noice").setup({})
end)

local k = vim.keymap
k.set( { "n", "x", "o" }, "s", function() require("flash").jump() end )
k.set( { "n", "x", "o" }, "S",  function() require("flash").treesitter() end, {desc = "Flash Treesitter" })
k.set(     {"o"}, "r"               ,function() require("flash").remote() end,            {desc = "Remote Flash" })
k.set( { "o", "x" }, "R",      function() require("flash").treesitter_search() end, {desc = "Treesitter Search" })
k.set({ "n", "x" }, "<leader>ca", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true })
