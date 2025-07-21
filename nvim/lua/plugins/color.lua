return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        show_end_of_buffer = true,
        -- background = {
        --   light = "latte",
        -- },
        dim_inactive = {
          enabled = false,
          percentage = .30
        },
        integrations = {
          gitsigns = false,
          cmp = true,
          treesitter = true,
          notify = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        }
      })
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin-frappe"
    end,
  }
}
