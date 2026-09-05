vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
  { src = "https://github.com/rachartier/tiny-code-action.nvim"}
})

-- Forward declaration: the ~/code read-only repo browser. Defined further down
-- alongside its keymap so the starter launchpad item and <Space>mic share one
-- implementation. Declared here so the closure below captures it as an upvalue.
local open_code_repo

local starter = require("mini.starter")

-- Recent-files label: the name of the file's repo root folder (nearest .git
-- ancestor), e.g. " (dotfiles)". Falls back to the immediate parent dir name
-- when the file isn't inside a git repo. Keeps entries short while still telling
-- you which project a same-named file belongs to.
local function repo_label(path)
  local root = vim.fs.root(path, ".git")
  local folder = root and vim.fn.fnamemodify(root, ":t") or vim.fn.fnamemodify(path, ":h:t")
  return string.format(" (%s)", folder)
end

starter.setup({
  items = {
    -- Launchpad: jump straight into the pickers instead of just files.
    { section = "Search", name = "Find files",        action = function() require("mini.pick").builtin.files() end },
    { section = "Search", name = "Live grep",         action = function() require("mini.pick").builtin.grep_live() end },
    { section = "Search", name = "Open buffers",      action = function() require("mini.pick").builtin.buffers() end },
    { section = "Search", name = "Browse ~/code repo", action = function() open_code_repo() end },

    -- Single recent-files section (was two overlapping ones), labelled with the
    -- file's repo/root folder so same-named files stay distinguishable.
    starter.sections.recent_files(10, false, repo_label),
    starter.sections.sessions(5, true),
    starter.sections.builtin_actions(),
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.indexing("all", { "Builtin actions" }),
    starter.gen_hook.aligning("center", "center"),
  },
  footer = function()
    local v = vim.version()
    return string.format(
      "nvim v%d.%d.%d  •  cwd: %s",
      v.major, v.minor, v.patch,
      vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    )
  end,
})
require("mini.pick").setup({
  -- Scroll with <C-d>/<C-u> (like normal-mode half-page scroll). <C-u> is
  -- default-bound to delete_left, so move that to <C-BS> to keep it available.
  mappings = {
    scroll_down = "<C-d>",
    scroll_up   = "<C-u>",
    delete_left = "<C-BS>",
  },
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
require("mini.git").setup({})
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
  local fileinfo     = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  -- Build the filename from the real buffer path (section_filename returns
  -- statusline field codes like "%F%m%r", not a path, so it can't be gsub'd).
  -- ':~:.' keeps it short and cheap: relative to cwd when the file lives under
  -- it (for <Space>mic tabs cwd is tcd'd to the repo root, so this is the
  -- root-relative path), else home-relative with '~'. Pure string ops — no
  -- git-root/filesystem walk — so it's fine to recompute on every redraw.
  -- Escape any '%' so the statusline won't interpret it, and append a modified
  -- flag (readonly is shown by its own chip below).
  local path = vim.fn.expand("%:~:.")
  local filename = (path == "" and "%t" or path:gsub("%%", "%%%%"))
    .. (vim.bo.modified and "[+]" or "")
  -- Force the short location form ('%l│%2v'): a huge trunc_width makes
  -- is_truncated() always true so it never expands to line|total│col.
  local location     = MiniStatusline.section_location({ trunc_width = math.huge })
  local search       = MiniStatusline.section_searchcount({ trunc_width = 75 })
  -- Read-only chip: shown for repos opened via <Space>mic and any other
  -- non-modifiable/readonly buffer (help, etc.).
  local readonly     = (vim.bo.readonly or not vim.bo.modifiable) and "RO" or ""

  return MiniStatusline.combine_groups({
    { hl = "MiniStatuslineNvim",     strings = { "nvim" } },
    { hl = mode_hl,                  strings = { mode } },
    { hl = "MiniStatuslineReadonly", strings = { readonly } },
    { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics, lsp } },
    { hl = "MiniStatuslineFilename", strings = { filename } },
    { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
    { hl = mode_hl,                  strings = { search, location } },
  })
end

-- Per-window statuslines (laststatus=2), but only the ACTIVE window's bar has
-- content — the inactive content is blank. So with splits, the bar full of info
-- sits directly under the focused pane and doubles as the "which pane is active"
-- indicator, while inactive panes show an empty bar.
require("mini.statusline").setup({
  content = {
    active = statusline_active,
    inactive = function() return "" end,
  },
})

vim.o.laststatus = 2

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


-- Tabpage-based tabline (one entry per tab, so splits/buffers are NOT shown as
-- separate tabs). Like the built-in one (tab number + active buffer's filename +
-- modified "[+]"), but prefixes the label to annotate that tab's active buffer:
--   [R] read-only / non-modifiable (e.g. repos opened via <Space>mic)
--   [S] not saveable to disk (non-file buftype, e.g. :Scratch nofile buffers)
function _G.custom_tabline()
	local s = ""
	for i = 1, vim.fn.tabpagenr("$") do
		local winnr = vim.fn.tabpagewinnr(i)
		local buflist = vim.fn.tabpagebuflist(i)
		local bufnr = buflist[winnr]

		-- Highlight group for the selected vs. non-selected tab.
		s = s .. (i == vim.fn.tabpagenr() and "%#TabLineSel#" or "%#TabLine#")
		-- Make the tab clickable (jumps to tab i).
		s = s .. "%" .. i .. "T"

		local name = vim.fn.bufname(bufnr)
		local label = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")

		local ro = vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable
		-- A normal, saveable file buffer has an empty buftype; any other buftype
		-- (nofile, nowrite, terminal, prompt, help, quickfix, ...) can't be :w'd.
		local unsaveable = vim.bo[bufnr].buftype ~= ""
		-- Combine independent flags into one bracket group: [R], [S], or [RS].
		local flags = (ro and "R" or "") .. (unsaveable and "S" or "")
		local prefix = flags ~= "" and ("[" .. flags .. "] ") or ""
		local modified = vim.bo[bufnr].modified and " [+]" or ""

		s = s .. " " .. prefix .. label .. modified .. " "
	end
	-- Fill the rest of the tabline and reset clickable region.
	s = s .. "%#TabLineFill#%T"
	return s
end

vim.o.tabline = "%!v:lua.custom_tabline()"

-- In the default colorscheme TabLineSel is only `bold` (no bg) and bottoms out at
-- an empty highlight with a transparent Normal, so the active tab doesn't stand
-- out. Force a solid reverse-video block and dim inactive tabs; re-applied on
-- ColorScheme so it survives theme reloads.
local function set_tabline_hl()
	vim.api.nvim_set_hl(0, "TabLineSel", { reverse = true, bold = true })
	vim.api.nvim_set_hl(0, "TabLine", { link = "StatusLineNC" })
	vim.api.nvim_set_hl(0, "TabLineFill", { link = "StatusLineNC" })
end
set_tabline_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_tabline_hl })

local maps = vim.keymap


-- STATIC browser: always anchored at the repo that <Space>mic opened for THIS
-- tab (vim.t.mic_root), regardless of the current buffer. Falls back to the tab
-- cwd (mic tcd's into the repo) and then the global cwd for non-mic tabs.
-- use_latest=false so it deterministically reopens at the root each time.
maps.set(
	{"n"},
	"<Space>mit",
	function()
		local mini = require("mini.files")
		if not mini.close() then
			local root = vim.t.mic_root or vim.fn.getcwd()
			mini.open(root, false)
		end
	end,
	{ desc = "mini.files at the <Space>mic repo root (static)" }
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
  end,
  { desc = "mini.files at the current file (dynamic)" }
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

-- Assigns the forward-declared local (see top of file), so the starter
-- launchpad item and the <Space>mic keymap below share this one implementation.
open_code_repo = function()
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
						-- Remember this tab's repo root so <Space>mit (static) and the
						-- grep pickers (via getcwd) always scope to it.
						vim.t.mic_root = root
						if not vim.tbl_contains(ro_roots, root) then
							table.insert(ro_roots, root)
						end
						require("mini.files").open(root)
					end)
				end,
			},
		}
	)
end

maps.set({ "n" }, "<Space>mic", open_code_repo, { desc = "Open a ~/code repo read-only in a new tab" })

-- Determine the directory a grep/file picker should be scoped to, based on the
-- CURRENT BUFFER rather than the tab. This is what lets side-by-side splits each
-- search their own repo: <Space>gp/gf/gap/gep scope to the *focused* window's
-- buffer, so two repos open next to each other don't share one scope.
-- Resolution order:
--   1. If the buffer lives under a repo opened read-only via <Space>mic, use that root.
--   2. Else the buffer's nearest `.git` ancestor (its own project root).
--   3. Else the tab's mic_root (set by <Space>mic), for nameless/starter buffers.
--   4. Else nil -> pickers fall back to their default (getcwd).
local function buffer_root()
	local name = vim.api.nvim_buf_get_name(0)
	if name ~= "" then
		local path = vim.fs.normalize(name)
		-- 1. Read-only repos opened via <Space>mic.
		for _, root in ipairs(ro_roots) do
			if path == root or path:sub(1, #root + 1) == root .. "/" then
				return root
			end
		end
		-- 2. Nearest .git ancestor of the buffer's own file.
		local git_root = vim.fs.root(path, ".git")
		if git_root then
			return vim.fs.normalize(git_root)
		end
	end
	-- 3. Fall back to this tab's mic root (for starter/nameless buffers).
	return vim.t.mic_root
end

-- Scope the grep/file pickers to the current buffer's root; otherwise return {}
-- so they keep their default (getcwd).
local function scoped_opts()
	local root = buffer_root()
	return root and { source = { cwd = root } } or {}
end

maps.set({"n"}, "<Space>gp",
function()
	require("mini.pick").builtin.grep_live({}, scoped_opts())
end
)

maps.set({"n"}, "<Space>gf",
function()
	require("mini.pick").builtin.files({}, scoped_opts())
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
	require("mini.pick").builtin.grep_live({}, scoped_opts())
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
	local root = buffer_root() or "."
	MiniPick.builtin.cli(
		{ command = { "find", root, "-name", ".git", "-prune", "-o", "-type", "d", "-print" } },
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
    }, scoped_opts())
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
