local home = os.getenv("HOME")
vim.g.mapleader = " "

vim.o.relativenumber = true
vim.o.number = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.ignorecase = true
vim.o.wildmenu = 'full'

vim.cmd [[ set mouse=a ]]

vim.opt.wildignore:append { '*/node_modules*' }
vim.opt.hlsearch = true
vim.opt.clipboard:append {'unnamed'}
vim.g.doge_enable_mappings = 0
vim.g.session_dir = home .. '/.config/nvim/sessions/'

vim.keymap.set('n', '+', '<C-a>')
vim.keymap.set('n', '-', '<C-x>')
vim.keymap.set('n', '<F3>', ':set list!<CR>')
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>')
vim.keymap.set('n', '<leader>ss', ':mks ' .. vim.g.session_dir .. vim.fn.expand('%:r') .. '.vim')
vim.keymap.set('n', '<leader>sr', ':so ' .. vim.g.session_dir)

local opt = vim.opt
local cmd = vim.cmd
local api = vim.api
local nvim_create_autocmd = api.nvim_create_autocmd
local nvim_set_hl = api.nvim_set_hl

opt.list = true

local space = "·"
opt.listchars:append {
	tab = "│─",
	multispace = space,
	lead = space,
	trail = space,
	nbsp = space
}

cmd([[match TrailingWhitespace /\s\+$/]])

nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })

nvim_create_autocmd("InsertEnter", {
	callback = function()
		opt.listchars.trail = nil
		nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
	end
})

nvim_create_autocmd("InsertLeave", {
	callback = function()
		opt.listchars.trail = space
		nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })
	end
})


-- :h option-list
-- :h E355
vim.o.directory = home .. '/.config/nvim/swapfiles/'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

