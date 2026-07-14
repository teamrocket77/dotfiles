vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
  { src = "https://github.com/rachartier/tiny-code-action.nvim"}
})

require("mini.starter").setup()
require("mini.pick").setup()
require("mini.icons").setup()
require("mini.files").setup({})
require("mini.extra").setup({})
require("mini.sessions").setup({})


local maps = vim.keymap


maps.set(
	{"n"},
	"<Space>mit",
	function()
		local mini = require("mini.files")
		if not mini.close() then
			mini.open(nil, true)
		end
	end
)
maps.set(
	{"n"},
	"<Space>mif",
  function()
    local mini = require("mini.files")
    if not mini.close() then
  	mini.open(vim.api.nvim_buf_get_name(0))
    end
  end
)

maps.set({"n"}, "<Space>gp", 
function()
	require("mini.pick").builtin.grep_live()
end
  )
maps.set('n', '<leader>gfp', function()
  vim.ui.input({ prompt = 'Extension to search (e.g., c, nix, lua): ' }, function(input)
    -- Cancel if you press Escape or leave it blank
    if not input or input == "" then return end
    
    -- Format the input into a ripgrep-compatible glob pattern
    local glob_pattern = "*." .. input
    
    -- Launch mini.pick with the dynamic glob filter
    MiniPick.builtin.grep_live({
      tool = 'rg',
      globs = { glob_pattern }
    })
  end)
end, { desc = 'Live Grep by Filetype on Invocation' })
maps.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { 
    buffer = 0, 
    desc = "See available code actions" 
})
maps.set({"n"}, "gls", function() require("mini.extra").pickers.lsp() end)
