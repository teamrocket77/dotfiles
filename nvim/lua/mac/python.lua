vim.lsp.config("basedpyright", {
  settings = {
    analysis = {
      venvPath = ".",
      venv = ".venv",
      autoSearchPaths = true,
      typeCheckingMode = "standard",
      diagnosticMode = "openFilesOnly",
      useLibraryCodeForTypes = true,
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
        functionReturnTypes = true,
        genericTypes = true,
      },
    },
  },
})

vim.lsp.config("ruff", {
  settings = {
    configuration = {
      lint = {
        select = { "ALL" },
        ignore = {
          "ANN",  -- flake8-annotations
          "COM",  -- flake8-commas
          "C90",  -- mccabe complexity
          "DJ",   -- django
          "EXE",  -- flake8-executable
          "T10",  -- debugger
          "TID",  -- flake8-tidy-imports
          "D100", -- ignore missing docs
          "D101",
          "D102",
          "D103",
          "D104",
          "D105",
          "D106",
          "D107",
          "D200",
          "D205",
          "D212",
          "D400",
          "D401",
          "D415",
          "E402",   -- false positives for local imports
          "E501",   -- line too long
          "TRY003", -- external messages in exceptions are too verbose
          "TD002",
          "TD003",
          "FIX002", -- too verbose descriptions of todos
        },
      },
    },
  },
})
