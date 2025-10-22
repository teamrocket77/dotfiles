local home = os.getenv("HOME")
local opts = vim.o

vim.g.mapleader = " "

opts.autoindent = true
opts.ignorecase = false
opts.number = true
opts.relativenumber = true
opts.shiftwidth = 4
opts.smartindent = true
opts.smarttab = true
opts.softtabstop = 2
opts.tabstop = 4
opts.wildmenu = true
opts.spell = false
-- vim.opt.sessionoptions = "buffers,curdir,help,resize,tabpages,terminal, winsize,winpos"

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
-- log level setting
vim.lsp.set_log_level("info")

vim.opt.list = true

-- :h option-list
-- :h E355
vim.o.directory = home .. "/.config/nvim/swapfiles/"
lsp_functions = require("config.lsp_functions")
lsp_functions.require_lsp()

require("config.functions")
require("config.lazy")
require("config.maps")

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "None" })
