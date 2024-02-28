return {
  "ray-x/go.nvim",
  dependencies = {  -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local format_go_group = vim.api.nvim_create_augroup("GoFormat", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        require('go.format').goimport()
      end,
      group = format_go_group
    })
    vim.keymap.set("n", '<leader>ru', ':GoRun<CR>', {noremap = true, silent = true})
    vim.keymap.set("n", '<leader>tes', ':GoTest<CR>', {noremap = true, silent = true})
    require("go").setup()
    -- requres that gopls is installed enables <space>ru<enter> for running files
  end,
  event = {"CmdlineEnter"},
  ft = {"go", 'gomod'},
  -- build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
}

