-- fmt
return {
  -- { "armyers/Vim-Jinja2-Syntax" },
  { "neovim/nvim-lspconfig" },
  {
    "mason-org/mason.nvim",
    version = "v1.11.0",
    dependencies = {
      { "mason-org/mason-lspconfig.nvim", version = "v1.32.0" },
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "wesleimp/stylua.nvim" },
    },

    config = function()
      local functions = require("config.functions")

      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*slint" },
        command = "set filetype=slint",
      })

      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")
      mason.setup()
      mason_lsp.setup({
        automatic_installation = true,
        ensure_installed = functions.servers
      })
    end,
  },
}
