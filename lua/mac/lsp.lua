-- fmt
return {
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    version = "v1.10.0",
    dependencies = {
      { "williamboman/mason-lspconfig.nvim", version = "1.26.0" },
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "wesleimp/stylua.nvim" },
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

        vim.api.nvim_win_set_cursor(0, { 1, 0 })
      end

      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*slint" },
        command = "set filetype=slint",
      })

      local formatters = {
        lua = "stylua",
      }

      local function get_formatter(filetype)
        return formatters[filetype]
      end

      local function format_buffer()
        local filetype = vim.bo.filetype
        local formatter = get_formatter(filetype)
        if formatter then
          if formatter == "stylua" then
            require("stylua").format()
          else
            vim.lsp.buf.format({
              filter = function(client)
                return client.name == formatter
              end,
              async = false,
            })
          end
        else
          -- Fallback to default LSP formatting
          vim.lsp.buf.format({ async = false })
        end
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("FormatOnSave", {}),
        -- will check if the fmt is there before formatting file
        -- TODO make check for files if so then we apply that
        callback = function(ev)
          local opts = { buffer = ev.buf }
          local cursor_position = vim.api.nvim_win_get_cursor(0)
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
          local line_cutoff = 5
          print(get_formatter(vim.bo.filetype))
          if #lines <= line_cutoff then
            line_cutoff = #lines
          end
          for _, line in
            ipairs(vim.api.nvim_buf_get_lines(0, 0, line_cutoff, true))
          do
            if string.find(line, "fmt") then
              format_buffer()
            end
          end
          vim.api.nvim_win_set_cursor(0, cursor_position)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- currently managed by ASDF

      local lspconfig = require("lspconfig")
      lspconfig.gopls.setup({})
      lspconfig.ts_ls.setup({})
      lspconfig.svelte.setup({})
      lspconfig.clangd.setup({})
      lspconfig.sourcekit.setup({
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      })

      local linters = {
        "pylint",
        "asm-lsp",
        "yamllint",
      }
      local cfg = require("yaml-companion").setup({})
      local handlers = {
        function(server)
          lspconfig[server].setup({
            capabilities = capabilities,
          })
        end,
        ["graphql"] = function()
          lspconfig.graphql.setup({
            capabilities = capabilities,
            root_dir = lspconfig.util.root_pattern(
              ".graphqlconfig",
              ".graphqlrc",
              "package.json"
            ),
          })
        end,
        ["docker_compose_language_service"] = function()
          lspconfig.docker_compose_language_service.setup({
            capabilities = capabilities,
          })
        end,
        ["pylsp"] = function()
          lspconfig.pylsp.setup({
            settings = {
              pylsp = {
                pycodestyle = {
                  ignore = {},
                },
              },
            },
          })
        end,
        -- ["ruff"] = function()
        --   lspconfig.ruff.setup({
        --     on_attach = function(client, bufnr)
        --       client.server_capabilities.documentFormattingProvider = true
        --       vim.api.nvim_buf_set_keymap(
        --         bufnr,
        --         "n",
        --         "<leader>fmt",
        --         "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
        --         { noremap = true, silent = true }
        --       )
        --     end,
        --     init_options = {
        --       settings = {
        --         capabilities = capabilities,
        --       },
        --     },
        --   })
        -- end,
        ["terraformls"] = function()
          lspconfig.terraformls.setup({
            capabilities = capabilities,
            filetypes = {
              "terraform",
              "tf",
              "tfvars",
            },
          })
        end,
        ["rust_analyzer"] = function()
          lspconfig.rust_analyzer.setup({
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
                warningsAsHint = true,
              },
            },
          })
        end,
        ["yamlls"] = function()
          lspconfig.yamlls.setup(cfg)
        end,
        ["slint_lsp"] = function()
          lspconfig.slint_lsp.setup({})
        end,
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                diagnostics = {
                  globals = { "vim" },
                },
              },
            },
          })
        end,
      }

      local servers = {
        "slint_lsp",
        "rust_analyzer",
        "cmake",
        "lua_ls",
        "dockerls",
        "graphql",
        --"tsserver",
        "terraformls",
        "yamlls",
        -- "python-lsp-server",
        "bashls",
      }
      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")
      mason.setup()
      mason_lsp.setup({
        automatic_installation = true,
        ensure_installed = servers,
        handlers = handlers,
      })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
      vim.keymap.set("n", "<leader>flt", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>buf", get_lsp)
    end,
  },
}
