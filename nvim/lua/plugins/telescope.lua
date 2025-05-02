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
      local single_or_multi = function(bufnr)
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")
        local single_selection = actions_state.get_selected_entry()
        local multi_selection = actions_state.get_current_picker(bufnr):get_multi_selection()
        if not vim.tbl_isempty(multi_selection) then
          actions.close(bufnr)
          for _, file in pairs(multi_selection) do
            if file.path ~= nil then
              vim.cmd(string.format("edit %s", file.path))
            end
          end
          vim.cmd(string.format("edit %s", single_selection.path))
        else
          actions.select_default(bufnr)
        end
      end

      local open_with_trouble = require("trouble.sources.telescope").open
      local add_to_trouble = require("trouble.sources.telescope").add

      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "output/python",
            "output/layer",
          },
          mappings = {
            i = {
              ["c-t"] = open_with_trouble,
              ["<CR>"] = single_or_multi,
            },
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
