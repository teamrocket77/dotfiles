vim.lsp.config("lua_ls", {
  root_markers = { ".git" },
  settings = {
    Lua = {
      diagnostics = {
        "vim"
      },
      hint = {
        enable = true,
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      },
    },
  },
})
