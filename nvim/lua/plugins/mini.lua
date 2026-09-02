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
-- Statusline with a fixed "nvim" chip as the leftmost item, so it's obvious at
-- a glance that this bar belongs to nvim (vs tmux's status bar). The rest mirrors
-- mini.statusline's default active content.
local function statusline_active()
  local MiniStatusline = require("mini.statusline")
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git          = MiniStatusline.section_git({ trunc_width = 40 })
  local diff         = MiniStatusline.section_diff({ trunc_width = 75 })
  local diagnostics  = MiniStatusline.section_diagnostics({ trunc_width = 75 })
  local lsp          = MiniStatusline.section_lsp({ trunc_width = 75 })
  local filename     = MiniStatusline.section_filename({ trunc_width = 140 })
  local fileinfo     = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local location     = MiniStatusline.section_location({ trunc_width = 75 })
  local search       = MiniStatusline.section_searchcount({ trunc_width = 75 })
  -- Read-only chip: shown for repos opened via <Space>mic and any other
  -- non-modifiable/readonly buffer (help, etc.).
  local readonly     = (vim.bo.readonly or not vim.bo.modifiable) and "RO" or ""

  return MiniStatusline.combine_groups({
    { hl = "MiniStatuslineNvim",     strings = { "nvim" } },
    { hl = mode_hl,                  strings = { mode } },
    { hl = "MiniStatuslineReadonly", strings = { readonly } },
    { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics, lsp } },
    "%<", -- Mark general truncate point
    { hl = "MiniStatuslineFilename", strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
    { hl = mode_hl,                  strings = { search, location } },
  })
end

require("mini.statusline").setup({ content = { active = statusline_active } })

-- Distinct chip color for the "nvim" label; re-apply on colorscheme change so it
-- tracks the theme (mini defines MiniStatuslineModeNormal during setup).
local function set_statusline_nvim_hl()
  vim.api.nvim_set_hl(0, "MiniStatuslineNvim", { link = "MiniStatuslineModeNormal" })
  -- Read-only chip: reuse the "replace/visual"-style mode color so it reads as
  -- a warning that this buffer can't be edited.
  vim.api.nvim_set_hl(0, "MiniStatuslineReadonly", { link = "MiniStatuslineModeReplace" })
end
set_statusline_nvim_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_statusline_nvim_hl })
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

-- Read-only repo browser rooted at ~/code.
--   <Space>mic : pick a repo under ~/code, open it in a NEW tab whose cwd is
--                tab-scoped (tcd) to that repo, and browse it with mini.files.
-- Because the grep pickers below use getcwd(), gp/gap/gup/gep automatically
-- operate on the chosen repo while that tab is active. Every file opened from
-- within the repo (via mini.files or any grep picker) is marked read-only
-- (nomodifiable + readonly), so the whole tree behaves like `nvim -M`.
local ro_roots = {} -- absolute, normalized repo roots opened read-only

local function mark_readonly_under_roots(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then return end
	local path = vim.fs.normalize(name)
	for _, root in ipairs(ro_roots) do
		if path == root or path:sub(1, #root + 1) == root .. "/" then
			vim.bo[bufnr].modifiable = false
			vim.bo[bufnr].readonly = true
			return
		end
	end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("CodeRepoReadOnly", { clear = true }),
	callback = function(args) mark_readonly_under_roots(args.buf) end,
})

maps.set({ "n" }, "<Space>mic", function()
	local code = vim.fn.expand("~/code")
	if vim.fn.isdirectory(code) == 0 then
		vim.notify("~/code does not exist", vim.log.levels.WARN)
		return
	end
	local MiniPick = require("mini.pick")
	MiniPick.builtin.cli(
		{ command = { "find", code, "-mindepth", "1", "-maxdepth", "1", "-type", "d" } },
		{
			source = {
				name = "Repo under ~/code (read-only)",
				choose = function(item)
					if not item or item == "" then return end
					local root = vim.fs.normalize(item)
					-- Defer so this picker finishes tearing down before we
					-- open the new tab + browser.
					vim.schedule(function()
						vim.cmd("tabnew")
						vim.cmd("tcd " .. vim.fn.fnameescape(root))
						if not vim.tbl_contains(ro_roots, root) then
							table.insert(ro_roots, root)
						end
						require("mini.files").open(root)
					end)
				end,
			},
		}
	)
end, { desc = "Open a ~/code repo read-only in a new tab" })

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

maps.set({"n"}, "<Space>gw",
function()
	require("mini.pick").builtin.buffers()
end,
{ desc = "Fuzzy-find open buffers" }
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

-- Two-step unrestricted grep: pick a directory first, then live-grep inside it,
-- searching EVERYTHING incl. gitignored/hidden trees like .venv.
-- Step 1: a directory picker built from `find` (ignores .gitignore, so .venv/
--         and other ignored dirs are selectable). .git/ is pruned.
-- Step 2: grep_live scoped to the chosen dir via source.cwd, with rg's
--         --no-ignore --hidden pulled in through RIPGREP_CONFIG_PATH (rg-all.conf),
--         restored when the grep picker closes.
maps.set({"n"}, "<Space>gup",
function()
	local MiniPick = require("mini.pick")
	MiniPick.builtin.cli(
		{ command = { "find", ".", "-name", ".git", "-prune", "-o", "-type", "d", "-print" } },
		{
			source = {
				name = "Dir to grep (all)",
				choose = function(item)
					if not item or item == "" then return end
					-- Defer: let this picker finish tearing down (and fire its own
					-- MiniPickStop) before we set env + open the grep picker.
					vim.schedule(function()
						local prev = vim.env.RIPGREP_CONFIG_PATH
						vim.env.RIPGREP_CONFIG_PATH = vim.fn.stdpath("config") .. "/rg-all.conf"
						vim.api.nvim_create_autocmd("User", {
							pattern = "MiniPickStop",
							once = true,
							callback = function()
								vim.env.RIPGREP_CONFIG_PATH = prev
							end,
						})
						MiniPick.builtin.grep_live({}, { source = { cwd = item } })
					end)
				end,
			},
		}
	)
end,
{ desc = "Grep incl. gitignored (.venv etc.), pick dir first" }
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
