return {
  "rebelot/kanagawa.nvim", config = function()
     -- vim.cmd [[ colorscheme kanagawa ]]
     -- vim.cmd [[ hi Normal guibg=NONE ctermbg=NONE ]]
  end,
  {
    "marko-cerovac/material.nvim", config = function()
      --require('monokai').setup {}
      -- vim.opt.termguicolors = true
      -- vim.cmd [[ colorscheme material ]]
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
	{
	"sainnhe/gruvbox-material",
	priority = 1000,
	config = function()
		vim.o.background = "dark" -- or "light" for light mode
		vim.cmd("let g:gruvbox_material_background= 'hard'")
		vim.cmd("let g:gruvbox_material_transparent_background=2")
		vim.cmd("let g:gruvbox_material_diagnostic_line_highlight=1")
		vim.cmd("let g:gruvbox_material_diagnostic_virtual_text='colored'")
		vim.cmd("let g:gruvbox_material_enable_bold=1")
		vim.cmd("let g:gruvbox_material_enable_italic=1")
		vim.cmd([[colorscheme gruvbox-material]]) -- Set color scheme
		-- changing bg and border colors
		vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
		vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "Normal" })
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
	end,
}

}
