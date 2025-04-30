-- fmt
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-live-grep-args.nvim", version = "v1.0.0" },
      { "BurntSushi/ripgrep", version = "14.1.0" },
      { "nvim-lua/plenary.nvim" },
      { "folke/trouble.nvim" },
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
      local actions = require("telescope.actions")
      local open_with_trouble = require("trouble.sources.telescope").open
      local add_to_trouble = require("trouble.sources.telescope").add

      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          mappings = {
            i = { ["c-t"] = open_with_trouble },
            n = { ["c-t"] = open_with_trouble },
          },
        },
      })
    end,
  },
  {
    "someone-stole-my-name/yaml-companion.nvim",
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  },
  {
    "junegunn/fzf",
    build = function()
      vim.cmd([[Lazy load fzf.vim]])
      vim.fn["fzf#install"]()
    end,
    dependencies = { "junegunn/fzf.vim" },
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
}
