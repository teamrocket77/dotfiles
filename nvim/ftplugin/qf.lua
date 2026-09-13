-- Quickfix / location-list window: `dd` (normal) and `d` (visual) remove the
-- entry/entries under the cursor from the list, then keep the cursor in place.

local function delete_qf_items(first, last)
  local win = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local is_loclist = win.loclist == 1

  local items = is_loclist and vim.fn.getloclist(0) or vim.fn.getqflist()
  for i = last, first, -1 do
    table.remove(items, i)
  end

  -- "r" replaces the current list in place (no new stack entry).
  if is_loclist then
    vim.fn.setloclist(0, items, "r")
  else
    vim.fn.setqflist(items, "r")
  end

  local line = math.max(1, math.min(first, #items))
  if #items > 0 then
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end
end

vim.keymap.set("n", "dd", function()
  local lnum = vim.fn.line(".")
  delete_qf_items(lnum, lnum)
end, { buffer = true, desc = "Remove item from quickfix list" })

vim.keymap.set("x", "d", function()
  local first = math.min(vim.fn.line("."), vim.fn.line("v"))
  local last = math.max(vim.fn.line("."), vim.fn.line("v"))
  -- leave visual mode before mutating the list / moving the cursor
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  delete_qf_items(first, last)
end, { buffer = true, desc = "Remove items from quickfix list" })
