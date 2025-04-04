-- fmt
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    version = "v0.9.2",
    config = function()
      local treesitter = require("nvim-treesitter.configs")
      treesitter.setup({
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
        disable = function(lang, buf)
          local kb = 1024
          local ok, stats = pcall(vim.look.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats.size > (kb * 15) then
            return true
          end
        end,
        textobjects = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    version = "",
    config = function() end,
  },
  {
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    "nvim-treesitter/nvim-treesitter-textobjects",
    version = "",
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "<c-v>",
            },
          },
        },
      })
    end,
  },
  -- vim.keymap.set('n', '<leader>cf', ':GetCurrentFunctions<CR>', {noremap = true, silent = true})
  {
    "stevearc/aerial.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup()
      vim.keymap.set("n", "<leader>at", ":AerialToggle<CR>", { noremap = true, silent = true })
      -- vim.keymap.set('n', '<leader>ac', ':AerialClose<CR>', {noremap = true, silent = true})
    end,
  },
}
