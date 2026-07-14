local M = {}

M.clang_config = function()
	vim.lsp.config("clangd", {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
		}
	})
end

M.defualt_config  = function()
	vim.lsp.config("*", {
		---@param client vim.lsp.Client
		---@param bufnr integer
		on_attach = function(client, bufnr) end,

		capabilities = get_cmp(),
		---@param client vim.lsp.Client
		---@param bufnr integer
		on_init = function(client, bufnr)
			local settings = {
				buffer = 0,
				id = client.id,
			}
			local ft = vim.bo.filetype
			if client:supports_method("textDocument/inlayHints") and functions.inlay_hint_servers[client.name] == nil then
				print("Hinting is supported for this server it should be enabled")
			end
			local opts = { buffer = 0 }
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "ga", ":lua vim.lsp.buf.code_action()<CR>", opts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
			vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>dline", function()
				local underline = vim.diagnostic.config().underline
				vim.diagnostic.config({ underline = not underline })
			end, opts)
		end,
	})
end

M.diagnostic_config = function()
	vim.diagnostic.config({
		underline = false,
		virtual_text = {
			severity = {
				vim.diagnostic.severity.ERROR,
			},
			prefix = "<",
			suffix = ">",
			source = true,
		},
		-- update_in_insert = true,
		severity_sort = true,
		float = {
			source = true,
		},
	})
end


M.lua_config = function()
	vim.lsp.config("lua_ls", {
		root_markers = { ".git" },
		settings = {
			Lua = {
				diagnostics = {
					"vim"
				},
				hint = {
					enable = true,
				},
				runtime = {
					version = "LuaJIT",
				},
				telemetry = {
					enable = false,
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true)
				},
			},
		},
	})
end

M.python_config = function()

	local root_files = {
		"pyproject.toml",
		"requirements.txt",
		"pyrightconfig.json",
		"uv.lock",
	}

	vim.lsp.config("basedpyright", {
		root_dir = vim.fs.root(0, root_files),
		settings = {
			basedpyright = {
				analysis = {
					logLevel = "Trace",
					venvPath = ".",
					venv = ".venv",
					verboseOutput = true,
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					inlayHints = {
						variableTypes = true,
						callArgumentNames = true,
						functionReturnTypes = true,
						genericTypes = true,
					},
				},
			},
		}
	})

	vim.lsp.config("ruff", {
		init_options = {
			settings = {},
		}
	})
end
M.default_config = function()
	--[[
	cmd = xcrun -f sourcekit-lsp
	https://wojciechkulik.pl/ios/the-complete-guide-to-ios-macos-development-in-neovim
	vim.lsp.config("sourcekit", {
		cmd = {
			"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
			"-Xswiftc",
			"-sdk",
			"-Xswiftc",
			"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk",
			"-Xswiftc",
			"-target",
			"-Xswiftc",
			"iPhoneSimulator26.0"
		},
		capabilities = {
			workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			},
		},
	})
	vim.lsp.config("terraformls", {
		settings = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			{ experimental = { telementryVersion = 0 } }
		),
	})]]
end


function M.setup(tbl)
	tbl = tbl or {}


	vim.pack.add({
		{ src = "https://github.com/mason-org/mason.nvim", version = "2a6940af80375532e5e9e7c1f2fc6319a1b7a69d" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim", version = "a5671269a1ddfa7790cdf97c14e600e269da550f" },
		{ src = "https://github.com/neovim/nvim-lspconfig", version = "229b79051b380377664edc4cbd534930154921a1" }
	})


	local mason = require("mason")
	local mason_lsp = require("mason-lspconfig")
	local lsp = require("lspconfig")

	mason.setup()
	vim.print(tbl.servers)


	if tbl.servers ~= nil then 
		mason_lsp.setup({
			automatic_installation = true,
			ensure_installed = tbl.servers,
			automatic_enable = false
		})
	else
		vim.notify("Servers passed to mason config is nil")
		mason_lsp.setup({
			automatic_installation = false,
			automatic_enable = false
		})
	end

	for _, server in ipairs(tbl.servers) do
		vim.lsp.enable(server)
	end


end


vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = 1 })
end)

vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = 1 })
end)

vim.keymap.set("n", "<C-j>", function()
	vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = 1, float = 1 })
end)

vim.keymap.set("n", "<C-k>", function()
	vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = -1, float = 1 })
end)
vim.keymap.set("n", "<leader>flt", vim.diagnostic.open_float)
-- vim.keymap.set("n", "<leader>buf", functions.get_lsp)
-- vim.keymap.set("n", "<leader>thi", functions.toggle_hints)


return M
