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
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- currently managed by ASDF
      lspconfig.gopls.setup{
      }

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
      }
      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")
      mason.setup()
      mason_lsp.setup({
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
