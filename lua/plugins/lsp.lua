return {
  { 'neovim/nvim-lspconfig', },
  {
    "williamboman/mason.nvim", version = "v1.10.0", 
    dependencies = {
      {"williamboman/mason-lspconfig.nvim", version = "1.26.0"},
      { 'neovim/nvim-lspconfig', },
      {'hrsh7th/cmp-nvim-lsp'},
    },

    config = function()
      function get_lsp()
        local clients = vim.lsp.buf_get_clients()
        local client_info = vim.inspect(clients)
        local lines = vim.split(client_info, "\n")
        vim.cmd("new")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.bo.readonly = true

        vim.api.nvim_win_set_cursor(0, {1, 0})
      end

      local lspconfig = require("lspconfig")
      lspconfig.gopls.setup{
      }
      vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>sh', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end
      })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- currently managed by ASDF

      local linters = {
        "pylint",
        "asm-lsp",
        "yamllint",
      }

      local handlers = {
        function(server)
          lspconfig[server].setup{
            capabilities = capabilities
          }
        end,
        ["yamlls"] = function ()
          lspconfig.yamlls.setup {
            capabilities = capabilities,
            settings = {
              yaml = {
                keyordering = false
              }
            }
          }
        end,
        ["graphql"] = function ()
          lspconfig.graphql.setup({
            capabilities = capabilities,
            root_dir = lspconfig.util.root_pattern(".graphqlconfig", ".graphqlrc", "package.json"),
          })
        end,
        ["docker_compose_language_service"] = function ()
          lspconfig.docker_compose_language_service.setup {
            capabilities = capabilities,
          }
        end,
        ["pyright"] = function ()
			lspconfig.pyright.setup {
				settings = {
					analysis  = {
						python  = {
							autoSearchPaths = true,
						}
					}
				}
			}
		end,
        ["ruff_lsp"] = function ()
			lspconfig.ruff_lsp.setup {
				on_attach = function(client, bufnr)
					client.server_capabilities.documentFormattingProvider = true
					vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>fmt', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', {noremap=true, silent=true})
				end,
				init_options = {
					settings = {
						capabilities = capabilities,
					}
				}
			}
		end,
        ["terraformls"] = function ()
          lspconfig.terraformls.setup {
            capabilities = capabilities,
            filetypes = {
				"terraform",
				"tf",
				"tfvars",
			},
          }
        end,
        ["tsserver"] = function ()
          lspconfig.tsserver.setup {
            capabilities = capabilities,
          }
        end,
        ["lua_ls"] = function ()
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace"
                },
                diagnostics = {
                  globals = { "vim"},
                },
              }
            }
          }
        end,
      }

      local servers = {
        "cmake",
        "lua_ls",
        "dockerls",
        "pyright",
        "ruff_lsp",
        "graphql",
        "tsserver",
        "terraformls",
      }
      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")
      mason.setup()
      mason_lsp.setup({
        automatic_installation = true,
        ensure_installed = servers,
        handlers = handlers
      })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
      vim.keymap.set('n', '<leader>flt', vim.diagnostic.open_float)
      vim.keymap.set('n', '<leader>buf', get_lsp)
    end
  },
}
