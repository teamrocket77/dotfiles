vim.lsp.config("lua_ls", {
  root_markers = {'.git'},
  settings = {
    Lua = {
      hint = {
        enable = true,
      },
    },
  },
})
