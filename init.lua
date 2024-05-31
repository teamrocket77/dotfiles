vim.g.mapleader = " "

vim.o.relativenumber = true
vim.o.number = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.smartcase = true

vim.cmd [[ set mouse=a ]]

vim.keymap.set('n', '+', '<C-a>')
vim.keymap.set('n', '-', '<C-x>')
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>')

vim.opt.wildignore:append { '*/node_modules*' }
vim.opt.hlsearch = true
vim.opt.clipboard:append {'unnamed'}
vim.g.doge_enable_mappings = 0

-- :h option-list
-- :h E355
local home = os.getenv("HOME")
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

