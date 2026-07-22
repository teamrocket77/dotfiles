vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
  { src = "https://github.com/rachartier/tiny-code-action.nvim"}
})

require("mini.starter").setup()
require("mini.pick").setup({
  window = {
    config = function()
      local h = vim.o.lines
      local w = vim.o.columns
      return {
        width = math.floor(w * .90),
        height = math.floor(h * .7),
        col = math.floor(w * .75),
        row = math.floor(h * .1),
      }
    end
  }
})
-- Make the currently-selected picker item stand out (default links to CursorLine).
-- Re-applied on ColorScheme so it survives theme reloads.
local function set_pick_hl()
	vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { link = "Visual", bold = true })
end
set_pick_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_pick_hl })

require("mini.icons").setup()
require("mini.files").setup({})
require("mini.extra").setup({})
require("mini.sessions").setup({})
require("mini.statusline").setup({})
require("mini.snippets").setup({})
-- require("mini.hues").setup({})


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

maps.set({"n"}, "<Space>gf",
function()
	require("mini.pick").builtin.files()
end
)

-- Live grep including hidden dotfiles (still respects .gitignore).
-- Scopes rg's --hidden to this picker only via RIPGREP_CONFIG_PATH,
-- restored when the picker closes so <Space>gp keeps its defaults.
maps.set({"n"}, "<Space>gap",
function()
	local prev = vim.env.RIPGREP_CONFIG_PATH
	vim.env.RIPGREP_CONFIG_PATH = vim.fn.stdpath("config") .. "/rg.conf"
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniPickStop",
		once = true,
		callback = function()
			vim.env.RIPGREP_CONFIG_PATH = prev
		end,
	})
	require("mini.pick").builtin.grep_live()
end,
{ desc = "Live grep incl. hidden files" }
)

maps.set('n', '<leader>gep', function()
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

-- LSP symbol navigation via mini.pick (mini.extra)
maps.set({ "n" }, "gls", function()
	require("mini.extra").pickers.lsp({ scope = "document_symbol" })
end, { desc = "LSP document symbols (current file)" })

maps.set({ "n" }, "glS", function()
	require("mini.extra").pickers.lsp({ scope = "workspace_symbol" })
end, { desc = "LSP workspace symbols (project)" })
