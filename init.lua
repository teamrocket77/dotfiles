local home = os.getenv("HOME")
vim.g.mapleader = " "

vim.o.relativenumber = true
vim.o.number = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 2
vim.o.tabstop = 4
vim.o.ignorecase = true
vim.o.wildmenu = "full"
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true

vim.cmd([[ set mouse=a ]])

vim.opt.wildignore:append({ "*/node_modules*" })
vim.opt.hlsearch = true
vim.opt.clipboard:append({ "unnamed" })
vim.opt.path:append("**")
vim.opt.wildignore:append("__pycache__")
vim.opt.wildignore:append("*pyc")
vim.g.doge_enable_mappings = 0
vim.g.session_dir = home .. "/.config/nvim/sessions/"
vim.g.python3_host_prog = home .. "/.pyenv/versions/pynvim/bin/python"

vim.keymap.set("n", "+", "<C-a>")
vim.keymap.set("n", "-", "<C-x>")
vim.keymap.set("n", "<leader>tb", function()
  if vim.o.background == "light" then
    vim.o.background = "dark"
  else
    vim.o.background = "light"
  end
end, {})
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>")
vim.keymap.set(
  "n",
  "<leader>ss",
  ":mks " .. vim.g.session_dir .. vim.fn.expand("%:r") .. ".vim"
)
vim.keymap.set("n", "<leader>sr", ":so " .. vim.g.session_dir)

local opt = vim.opt
local cmd = vim.cmd
local api = vim.api
local nvim_create_autocmd = api.nvim_create_autocmd
local nvim_set_hl = api.nvim_set_hl

opt.list = true

local space = "·"
opt.listchars:append({
  tab = "│─",
  multispace = space,
  lead = space,
  trail = space,
  nbsp = space,
})

cmd([[match TrailingWhitespace /\s\+$/]])

nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })

nvim_create_autocmd("InsertEnter", {
  callback = function()
    opt.listchars.trail = nil
    nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
  end,
})

nvim_create_autocmd("InsertLeave", {
  callback = function()
    opt.listchars.trail = space
    nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })
  end,
})

local function toggle_zoom()
  local zoom_status = vim.g.zoom_status or 0
  if zoom_status == 0 then
    vim.cmd("wincmd _")
    vim.cmd("wincmd |")
    vim.g.zoom_status = 1
  else
    vim.cmd("wincmd =")
    vim.g.zoom_status = 0
  end
end
vim.keymap.set("n", "<leader>0", ":ToggleZoom<CR>")

vim.api.nvim_create_user_command("ToggleZoom", toggle_zoom, {})
-- :h option-list
-- :h E355
vim.o.directory = home .. "/.config/nvim/swapfiles/"
require("config.lazy")
