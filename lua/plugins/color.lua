return {
  "rebelot/kanagawa.nvim", config = function()
     -- vim.cmd [[ colorscheme kanagawa ]]
     -- vim.cmd [[ hi Normal guibg=NONE ctermbg=NONE ]]
  end,
  {
    "marko-cerovac/material.nvim", config = function()
      --require('monokai').setup {}
      vim.opt.termguicolors = true
      vim.cmd [[ colorscheme material ]]
      require('material').setup({
        contrast = {
          terminal = true
        },
        disable = {
          background = true
        }
      })
      vim.g.material_style = "deep ocean"
      vim.cmd [[ hi Normal ]]
    end
  },
}
