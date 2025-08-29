local home = os.getenv("HOME")
vim.g.mapleader = " "

vim.o.autoindent = true
vim.o.ignorecase = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 2
vim.o.tabstop = 4
vim.o.wildmenu = true

vim.cmd([[ set mouse=a ]])

local ignore_list = {
  "node_modules*",
  "*__pycache__/",
  "*pyc*",
  "*venv*",
  "*old_json*",
  "*old_csv*",
}
for _, path in ipairs(ignore_list) do
  vim.opt.wildignore:append(path)
end

vim.opt.path:append("**")
vim.opt.clipboard:append({ "unnamed" })

vim.opt.hlsearch = true
vim.g.doge_enable_mappings = 0
vim.g.python3_host_prog = home .. "/.pyenv/versions/pynvim/bin/python"
-- vim.lsp.set_log_level("off")

vim.opt.list = true

-- :h option-list
-- :h E355
vim.o.directory = home .. "/.config/nvim/swapfiles/"
require("mac.init")
require("config.lazy")
require("config.functions")
require("config.maps")
