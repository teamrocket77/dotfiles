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
  -- vim.keymap.set('n', '<leader>cf', ':GetCurrentFunctions<CR>', {noremap = true, silent = true})
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    }, config = function()
      require('aerial').setup()
      vim.keymap.set('n', '<leader>at', ':AerialToggle<CR>', {noremap = true, silent = true})
      -- vim.keymap.set('n', '<leader>ac', ':AerialClose<CR>', {noremap = true, silent = true})
    end,
  }
}
