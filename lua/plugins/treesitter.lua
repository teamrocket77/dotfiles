return {
  {
    'nvim-treesitter/nvim-treesitter', build = ':TSUpdate',
    version = "v0.9.2",
    config = function()
      local treesitter = require('nvim-treesitter.configs')
      treesitter.setup{
        ensure_installed = {
          "bash",
          "dockerfile",
          "rust",
          "markdown",
          "yaml",
          "json",
          "c",
          "lua",
          "python",
        },
        auto_install = true,
        textobjects = {
          enable = true,
        },
      }
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    version = "",
    config = function()
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    version = "",
    config = function()
    end
  },
}
