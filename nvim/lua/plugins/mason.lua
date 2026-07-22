vim.pack.add({
  { src = "https://github.com/hrsh7th/nvim-cmp", version = "8c82d0b"},
  { src = "https://github.com/saadparwaiz1/cmp_luasnip",            version = "98d9cb5" },
  { src = "https://github.com/L3MON4D3/LuaSnip",                    version = "4585605" },
  { src = "https://github.com/rafamadriz/friendly-snippets",        version = "572f566" },
  { src = "https://github.com/hrsh7th/cmp-cmdline",                 version = "d126061" },
  { src = "https://github.com/hrsh7th/cmp-path",                    version = "c6635aa" },
  { src = "https://github.com/hrsh7th/cmp-buffer",                  version = "b74fab3" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lua",                version = "f12408b" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp",                version = "a8912b8" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help", version = "031e6ba" },
})

local M = {}
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  enabled = function()
    local disabled = false
    disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
    disabled = disabled or (vim.fn.reg_recording() ~= "")
    disabled = disabled or (vim.fn.reg_executing() ~= "")
    disabled = disabled or require("cmp.config.context").in_treesitter_capture("comment")
    return not disabled
  end,
  performance = { max_view_entries = 7 },
  matching = {
    disallow_fuzzy_matching = false,
    disallow_fullfuzzy_matching = false,
    disallow_symbol_nonprefix_matching = false,
    disallow_partial_fuzzy_matching = false,
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif #cmp.get_entries() == 1 then
          cmp.confirm({ select = true })
        end
      elseif vim.api.nvim_get_mode().mode == "i" then
        local expandtab = vim.bo.expandtab
        local shiftwidth = vim.bo.shiftwidth
        if expandtab then
          vim.api.nvim_feedkeys(string.rep(" ", shiftwidth), "i", true)
        else
          vim.api.nvim_feedkeys("\t", "n", true)
        end
      else
        fallback()
      end
    end
    )
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp", },
    { name = "luasnip", },
    { name = "buffer", },
    -- { name = "nvim_lsp_signature_help", },
    { name = "nvim_lua", },
    {
      name = "path",
      option = {
        get_cwd = function()
          return vim.fn.getcwd()
        end
      }
    },
  }),
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
      {
        name = "path",
        option = {
          get_cwd = function()
            return vim.fn.getcwd()
          end
        }
      }
    },
    {
      {
        name = "cmdline",
        max_item_count = max_item_count,
        option = {
          ignore_cmds = { "Man", "!" }
        }
      }
    })
})
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if luasnip.jumpable(1) then
    luasnip.jump(1)
  end
end)
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end)

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

local get_cmp = function()
  local ok, module = pcall(require, "cmp_nvim_lsp")
  if not ok then
    return nil
  end
  return module.default_capabilities()
end

M.default_config  = function()

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

M.yaml_config = function()
	-- yamlls attaches to `yaml.gitlab` too, so it layers schema completion/
	-- validation on top of gitlab-ci-ls' cross-file intelligence.
	-- The GitLab CI schema is vendored locally (schemas/gitlab-ci.json) because
	-- GitLab's raw endpoint is Cloudflare-gated and 429s non-browser clients.
	local gitlab_ci_schema = vim.fs.joinpath(vim.fn.stdpath("config"), "schemas", "gitlab-ci.json")
	vim.lsp.config("yamlls", {
		settings = {
			yaml = {
				-- GitLab's `!reference [...]` is a custom YAML tag; declare it so
				-- yamlls stops flagging it as an unknown/unresolved tag. It takes a
				-- sequence argument. (gitlab-ci-ls resolves the target itself.)
				customTags = {
					"!reference sequence",
				},
				schemaStore = {
					enable = true,
					url = "https://www.schemastore.org/api/json/catalog.json",
				},
				schemas = {
					[gitlab_ci_schema] = {
						".gitlab-ci.yml",
						"*.gitlab-ci.yml",
						"**/*ci*.yml",
						"**/*ci*.yaml",
					},
				},
			},
		},
	})
end

M.gitlab_config = function()
	-- Dedicated GitLab CI language server: include/extends/!reference resolution,
	-- go-to-definition across files, job hover. Attaches to `yaml.gitlab` buffers.
	local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "gitlab-ci-ls")
	vim.lsp.config("gitlab_ci_ls", {
		init_options = {
			cache_path = cache_dir,
			log_path = vim.fs.joinpath(cache_dir, "log", "gitlab-ci-ls.log"),
		},
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

  M.default_config()
  M.python_config()
  M.yaml_config()
  M.gitlab_config()

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
