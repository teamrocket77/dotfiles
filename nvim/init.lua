local home = os.getenv("HOME")
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 2
vim.o.tabstop = 4
vim.o.ignorecase = true
vim.o.wildmenu = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true

vim.cmd([[ set mouse=a ]])

local ignore_list = {
  "node_modules*",
  "unnamed/",
  "__pycache__/",
  "*pyc",
}
for _, path in ipairs(ignore_list) do
  vim.opt.wildignore:append(path)
end

vim.opt.path:append("**")

vim.opt.hlsearch = true
vim.g.doge_enable_mappings = 0
vim.g.python3_host_prog = home .. "/.pyenv/versions/pynvim/bin/python"

vim.opt.list = true

-- :h option-list
-- :h E355
vim.o.directory = home .. "/.config/nvim/swapfiles/"
require("config.lazy")
