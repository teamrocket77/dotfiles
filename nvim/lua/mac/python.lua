-- local util = require("lspconfig.util")
local root_files = {
  "pyproject.toml",
  "requirements.txt",
  "pyrightconfig.json",
  "uv.lock",
}




vim.lsp.config("basedpyright", {
  root_dir = vim.fs.root(0, root_files),
  settings = {
    basedpyright = {
      analysis = {
        logLevel = "Trace",
        venvPath = ".",
        venv = ".venv",
        verboseOutput = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = true,
        },
      },
    },
  }
})

vim.lsp.config("ruff", {
  init_options = {
    settings = {},
  }
})
