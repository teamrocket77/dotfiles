local keymap = vim.keymap
keymap.set("n", "<leader>tb", function()
  if vim.o.background == "light" then
    vim.o.background = "dark"
  else
    vim.o.background = "light"
  end
end, {})

keymap.set("n", "<leader>tn", ":tabnew<CR>")
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')
keymap.set('n', '<leader>tn', ':tabnew<CR>')
keymap.set("n", "<F3>", ':exec &bg=="light"? "set bg=dark" : "set bg=light"<CR>', {noremap = true, silent = true})
keymap.set("n", "<leader>0", ":ToggleZoom<CR>")
keymap.set("n", "<leader>tv", ":!terraform validate<CR>")
