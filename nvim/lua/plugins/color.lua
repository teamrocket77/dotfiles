return {
  -- {
  --   "folke/tokyonight.nvim",
  --   config = function()
  --     require("tokyonight").setup({
  --       transparent = true,
  --       styles = {
  --         sidebars = "transparent",
  --         floats = "transparent",
  --       },
  --       on_colors = function(colors)
  --         colors.comment = "#3599AE"
  --       end,
  --     })
  --     vim.cmd.colorscheme "tokyonight-night"
  --   end,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        show_end_of_buffer = true,
        background = {
          light = "latte",
        },
        dim_inactive = {
          enabled = false,
          percentage = .30
        },
        integrations = {
          gitsigns = false,
          mini = {
            enabled = false,
          }
        }
      })
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin-frappe"
    end,
  }
}
