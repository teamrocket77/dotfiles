vim.lsp.config("nushell", {
  cmd = { "nu", "--lsp" },
  filetypes = { "nu" },
  root_dir = vim.fs.dirname(vim.fs.find(".git", { path = startpath, upward = true })[1]),
  single_file_support = true,
})
