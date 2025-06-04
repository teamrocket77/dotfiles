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

local function remove_qf_item()
  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line(".")
  local current_bufnr = vim.api.nvim_get_current_buf()

  print("Current line:", current_line)
  print("Current buffer number:", current_bufnr)

  local new_qflist = {}
  local removed = false

  for i, item in ipairs(qflist) do
    print("Item", i, ":")
    print("  bufnr:", item.bufnr)
    print("  lnum:", item.lnum)
    print("  text:", item.text) -- Print the text to help identify the item

    if item.bufnr == current_bufnr and item.lnum == current_line then
      print("  Match found! Skipping item.")
      removed = true
    else
      table.insert(new_qflist, item)
    end
  end

  if removed then
    vim.fn.setqflist(new_qflist, "r") -- 'r' replaces the existing list
    print("Removed item from quickfix list.")
  else
    print("No matching item found in quickfix list at current line and buffer.")
  end
end

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

local function add_matching_buffers_to_args(pattern)
  local current_bufnr = vim.api.nvim_get_current_buf() -- Save current buffer number
  local buflist = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      if string.find(bufname, pattern) then
        table.insert(buflist, bufname)
      end
    end
  end

  if #buflist > 0 then
    vim.cmd("args add " .. table.concat(buflist, " "))
    vim.api.nvim_command("buffer " .. current_bufnr) -- Switch back to the original buffer
  else
    vim.notify("No buffers matched the pattern.")    -- Requires a notification plugin
    -- Or use: vim.cmd("echo 'No buffers matched the pattern.'")
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
nvim_create_user_command(
  "AddBuffersToArgs",
  function(opts)
    add_matching_buffers_to_args(opts.args)
  end,
  { nargs = 1, desc = "Add buffers matching a regex pattern to the args list" }
)
nvim_create_user_command("RemoveQFItem", remove_qf_item, {})


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
vim.api.nvim_command("autocmd FileType qf nnoremap <buffer> dd :RemoveQFItem<cr>")
-- Return an empty table to satisfy plugin loader requirements
local lsp_functions = {}

lsp_functions.formatting_options = {
  python = "ruff"
}

---@param ev table
---@param settings table
lsp_functions.conditional_formatting = function(ev, settings)
  local ft           = vim.bo.filetype
  local final_client = nil
  local clients      = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" })
  if lsp_functions.formatting_options[ft] ~= nil then
    for _, client_v in pairs(clients) do
      if client_v.name == lsp_functions.formatting_options[ft] then
        final_client = client_v
      end
    end
  else
    -- take any server that supports formatting if it's not defined
    local final_client = clients[1].name
  end
  if final_client == nil then
    return
  end

  local cursor_position = vim.api.nvim_win_get_cursor(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local line_cutoff = 5
  settings = vim.tbl_deep_extend('force', settings, {
    filter = function(client)
      return client.name == lsp_functions.formatting_options[ft]
    end,
    id = final_client.id
  })
  if #lines <= line_cutoff then
    line_cutoff = #lines
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, line_cutoff, true)) do
    if string.find(line, "fmt") then
      vim.lsp.buf.format(settings)
      return
    end
  end
  vim.api.nvim_win_set_cursor(0, cursor_position)
end

lsp_functions.have_go_ls_installed = function()
  if os.execute("go version > /dev/null 2>&1") == 0 then
    return "gopls"
  else
    return nil
  end
end

lsp_functions.have_ghcup_ls_installed = function()
  if os.execute("ghcup -h > /dev/null 2>&1") == 0 then
    return "hls"
  else
    return ""
  end
end

lsp_functions.inlay_hint_servers = {
  lua_ls = true,
  basedpyright = true,
}


lsp_functions.get_lsp = function()
  local clients     = vim.lsp.get_clients({ bufnr = 0 })
  local client_info = vim.inspect(clients)
  local lines       = vim.split(client_info, "\n")

  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.readonly = true

  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end


lsp_functions.toggle_hints = function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { 0 })
end

local have_ruby = function()
  if os.execute('rbenv 2>&1') == 0 then
    return "ruby_lsp"
  end
  return ""
end

lsp_functions.servers = {
  "slint_lsp",
  "rust_analyzer",
  "cmake",
  "lua_ls",
  "dockerls",
  "basedpyright",
  "pyright",
  "ruff",
  "graphql",
  "terraformls",
  "yamlls",
  "bashls",
  have_ruby(),
  lsp_functions.have_ghcup_ls_installed(),
  lsp_functions.have_go_ls_installed(),
}

return lsp_functions
