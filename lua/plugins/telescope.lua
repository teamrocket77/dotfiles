return {
  {
    "nvim-telescope/telescope.nvim", 
  dependencies = {
    { "nvim-telescope/telescope-live-grep-args.nvim", version = "v1.0.0" },
    { "BurntSushi/ripgrep", version = "14.1.0", },
    { "nvim-lua/plenary.nvim" },
    { "folke/trouble.nvim" },
  }, config = function()
    require("telescope").load_extension("live_grep_args")
    local actions = require("telescope.actions")
    local trouble = require("trouble.sources.telescope")

    local telescope = require("telescope")

    telescope.setup {
    }
  end,
  },
  {'someone-stole-my-name/yaml-companion.nvim',
    config = function()
      require('telescope').load_extension('yaml_schema')
  end
  },
  {
    'junegunn/fzf', build = function()
      vim.fn["fzf#install"]()
    end, dependencies = { 'junegunn/fzf.vim' },
  }
}
