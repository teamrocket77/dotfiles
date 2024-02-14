return {
  "nvim-telescope/telescope.nvim", 
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim", version = "v1.0.0"
    },
    {
      "BurntSushi/ripgrep", version = "14.1.0",
    },
    {
      "nvim-lua/plenary.nvim"
    },
  }, config = function()
    require("telescope").load_extension("live_grep_args")
  end
}
