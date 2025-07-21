vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
        warningsAsHint = true,
      },
    },
  },
})

vim.lsp.config("asm_lsp", {
  settings = {},
})
