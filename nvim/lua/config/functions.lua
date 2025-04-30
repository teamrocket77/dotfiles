local cmd = vim.cmd
local space = "·"
local opt = vim.opt

local nvim_set_hl = vim.api.nvim_set_hl
local nvim_create_user_command = vim.api.nvim_create_user_command
local nvim_create_autocmd = vim.api.nvim_create_autocmd

local gpgGroup = vim.api.nvim_create_augroup("customGpg", { clear = true })

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



vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		-- Make sure nothing is written to shada file while editing an encrypted file.
		vim.opt_local.shada = nil
		-- We don't want a swap file, as it writes unencrypted data to disk
		vim.opt_local.swapfile = false
		-- Switch to binary mode to read the encrypted file
		vim.opt_local.bin = true
		-- Save the current 'ch' value to a buffer-local variable
		vim.b.ch_save = vim.opt_local.ch:get()
		vim.cmd "set ch=2"
	end,
})

nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		vim.cmd "'[,']!gpg -d 2> /dev/null"
		-- Switch to normal mode for editing
		vim.opt_local.bin = false
		-- Restore the 'ch' value from the buffer-local variable
		vim.opt_local.ch = vim.b.ch_save
		vim.cmd "unlet b:ch_save"
		vim.cmd(":doautocmd BufReadPost " .. vim.fn.expand "%:r")
	end,
})

-- Convert all text to encrypted text before writing
nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		-- Switch to binary mode to write the encrypted file
		vim.opt_local.bin = true
		-- So we can avoid the armor option
		vim.cmd("'[,']!gpg -e 2>/dev/null")
	end,
})
-- Undo the encryption so we are back in the normal text, directly after the file has been written.
nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		vim.cmd("u")
		-- Switch to normal mode for editing
		vim.opt_local.bin = false
	end,
})

-- Return an empty table to satisfy plugin loader requirements
return {}
