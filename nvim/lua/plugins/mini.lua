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
require("mini.sessions").setup({
	-- autowrite: save the *active* session on exit (VimLeavePre). Combined with
	-- the VimEnter autoread below, opening a dir with a session -> edits are
	-- saved back automatically on quit.
	autowrite = true,
	-- Leave built-in autoread off: it falls back to the latest *global* session
	-- when the cwd has none. The VimEnter autocmd below reads the local session
	-- only, so startup restore is scoped strictly to the current directory.
	autoread = false,
})
require("mini.statusline").setup({})
require("mini.snippets").setup({})
-- require("mini.hues").setup({})

-- Autoread the current directory's local session on startup, but only when
-- Neovim was opened with no file arguments (mirrors mini's own guard). Unlike
-- built-in autoread this never restores a global session -- it fires solely
-- when THIS dir has a session file. The read makes it the active session, so
-- mini's autowrite then saves it back on exit.
vim.api.nvim_create_autocmd("VimEnter", {
	nested = true,
	once = true,
	callback = function()
		if vim.fn.argc() > 0 then return end
		local ms = require("mini.sessions")
		local file = ms.config.file
		if file ~= "" and ms.detected[file] ~= nil then
			ms.read(file)
		end
	end,
})


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
  	-- On the mini.starter/home screen (and other nameless buffers) the current
  	-- buffer has no file path, so mini.open("") errors. Fall back to the cwd.
  	local name = vim.api.nvim_buf_get_name(0)
  	local path = (name ~= "" and vim.loop.fs_stat(name)) and name or vim.fn.getcwd()
  	mini.open(path)
  	-- Force hidden/dotfiles to show for this picker only.
  	mini.refresh({ content = { filter = function() return true end } })
    end
  end
)

-- mini.sessions: save / load / delete under <Space>ms* (Mini Session).
-- Sessions are :mksession files kept in the configured directory.
maps.set({ "n" }, "<Space>msw", function()
	vim.ui.input({ prompt = "Save session as (blank = current): " }, function(name)
		if name == nil then return end -- cancelled with <Esc>
		require("mini.sessions").write(name ~= "" and name or nil)
	end)
end, { desc = "Session: write/save" })

maps.set({ "n" }, "<Space>msr", function()
	require("mini.sessions").select("read")
end, { desc = "Session: read/load (pick)" })

maps.set({ "n" }, "<Space>msd", function()
	require("mini.sessions").select("delete")
end, { desc = "Session: delete (pick)" })

-- Live grep that also searches otherwise-hidden files listed in
-- grep-extra.ignore (e.g. .gitlab-ci.{yml,yaml}). Those start with a dot, so
-- rg skips them by default. A scoped rg config adds that file as an
-- --ignore-file whose negations re-include exactly those matches, while still
-- honoring .gitignore and keeping every other dotfile hidden. Add more there.
-- RIPGREP_CONFIG_PATH is scoped to this picker and restored when it closes.
maps.set({"n"}, "<Space>gp",
function()
	local config = vim.fn.stdpath("config")
	local conf = vim.fn.stdpath("cache") .. "/gp-rg.conf"
	vim.fn.writefile({ "--ignore-file=" .. config .. "/grep-extra.ignore" }, conf)

	local prev = vim.env.RIPGREP_CONFIG_PATH
	vim.env.RIPGREP_CONFIG_PATH = conf
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniPickStop",
		once = true,
		callback = function()
			vim.env.RIPGREP_CONFIG_PATH = prev
		end,
	})
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
