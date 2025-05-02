-- fmt
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    version = "v0.25.3",
    config = function()
      local treesitter = require("nvim-treesitter.configs")
      treesitter.setup({
        ensure_installed = {
          "bash",
          "dockerfile",
          "rust",
          "terraform",
          "hcl",
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
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
          },
          select = {
            enable = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["bf"] = "@block.outer",
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
  {
    "nvim-treesitter/nvim-treesitter-context",
    version = "compat/0.7",
    config = function() end,
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
