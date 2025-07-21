return {
  "sindrets/diffview.nvim",
  commit = "4516612",
  config = function()
    require("diffview").setup({
      hooks = {
        diff_read_buf = function(_)
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = false
        end,
      }
    })
  end,
}
