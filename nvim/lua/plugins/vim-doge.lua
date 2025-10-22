return {
  "kkoomen/vim-doge",
  build = ":call doge#install()",
  config = function()
    vim.keymap.set("n", "<Leader>doc", "<Plug>(doge-generate)")
    vim.keymap.set("n", "<Leader>ton", "<Plug>(doge-comment-jump-forward)")
    vim.keymap.set("n", "<Leader>toN>", "<Plug>(doge-comment-jump-backward)")
    -- vim.g.doge_enable_mappings = 0
  end,
  ft = { "Python" },
}
