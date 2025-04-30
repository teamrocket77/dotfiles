local nvim_create_autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local space = "·"
local opt = vim.opt
local nvim_set_hl = vim.api.nvim_set_hl
local nvim_create_user_command = vim.api.nvim_create_user_command

opt.listchars:append({
  tab = "│─",
  multispace = space,
  lead = space,
  trail = space,
  nbsp = space,
})

local function toggle_zoom()
  local zoom_status = vim.g.zoom_status or 0
  if zoom_status == 0 then
    cmd("wincmd _")
    cmd("wincmd |")
    vim.g.zoom_status = 1
  else
    cmd("wincmd =")
    vim.g.zoom_status = 0
  end
end

local function diff_off_func()
  cmd('diffoff')
  cmd('q')
  cmd('diffoff')
end

local function diff_with_saved()
  local filetype = vim.bo.filetype
  cmd('diffthis')
  cmd('vnew | r # | normal! 1Gdd')
  cmd('diffthis')
  cmd('setlocal bt=nofile bh=wipe nobl noswf ro ft=' .. filetype)
end

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


nvim_create_user_command('DiffSaved', diff_with_saved, {})
nvim_create_user_command('DiffoffComplex', diff_off_func, {})
nvim_create_user_command("ToggleZoom", toggle_zoom, {})
