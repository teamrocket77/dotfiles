-- fmt
return {
  -- { "armyers/Vim-Jinja2-Syntax" },
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    version = "v1.11.0",
    dependencies = {
      { "williamboman/mason-lspconfig.nvim", version = "1.32.0" },
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
        local FoundRuff = false
        local cur_buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients({ bufnr = cur_buf })
        -- for updated neovim v.11
        -- local clients = vim.lsp.get_clients({ bufnr = cur_buf })
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
        elseif filetype == "python" then
          for _, client in ipairs(clients) do
            if "ruff" == client.name then
              FoundRuff = true
              break
            end
          end
          if FoundRuff then
            vim.lsp.buf.format({ { lineLength = 1 }, async = false })
          end
        else
          -- call some unspecified formatter
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
          if #lines <= line_cutoff then
            line_cutoff = #lines
          end
          for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, line_cutoff, true)) do
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
      local configs = require("lspconfig.configs")
      -- lspconfig.gopls.setup({})
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

      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      -- lspconfig.jinja_lsp.setup({
      --   capabilities = capabilities,
      -- })
      -- lspconfig.jinja_lsp.setup({})

      local linters = {
        "pylint",
        "asm-lsp",
        "yamllint",
      }
      local get_root_dir = function(fname)
        local root_files = {
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          ".git",
        }
        return lspconfig.util.root_pattern(unpack(root_files))(fname)
          or lspconfig.util.find_git_ancestor(fname)
          or lspconfig.util.path.dirname(fname)
      end
      local cfg = require("yaml-companion").setup({})
      local handlers = {
        ["graphql"] = function()
          lspconfig.graphql.setup({
            capabilities = capabilities,
            root_dir = lspconfig.util.root_pattern(".graphqlconfig", ".graphqlrc", "package.json"),
          })
        end,
        ["docker_compose_language_service"] = function()
          lspconfig.docker_compose_language_service.setup({
            capabilities = capabilities,
          })
        end,

        ["basedpyright"] = function()
          lspconfig.basedpyright.setup({
            settings = {
              basedpyright = {
                analysis = {
                  venvPath = ".",
                  venv = ".venv",
                  autoSearchPaths = true,
                  typeCheckingMode = "standard",
                  diagnosticMode = "openFilesOnly",
                  useLibraryCodeForTypes = true,
                },
              },
            },
            capabilities = capabilities,
          })
        end,
        ["ruff"] = function()
          -- https://docs.astral.sh/ruff/rules/
          lspconfig.ruff.setup({
            init_options = {
              settings = {
                capabilities = capabilities,
                configuration = {
                  lint = {
                    select = { "ALL" },
                    ignore = {
                      "ANN", -- flake8-annotations
                      "COM", -- flake8-commas
                      "C90", -- mccabe complexity
                      "DJ", -- django
                      "EXE", -- flake8-executable
                      "T10", -- debugger
                      "TID", -- flake8-tidy-imports
                      "D100", -- ignore missing docs
                      "D101",
                      "D102",
                      "D103",
                      "D104",
                      "D105",
                      "D106",
                      "D107",
                      "D200",
                      "D205",
                      "D212",
                      "D400",
                      "D401",
                      "D415",
                      "E402", -- false positives for local imports
                      "E501", -- line too long
                      "TRY003", -- external messages in exceptions are too verbose
                      "TD002",
                      "TD003",
                      "FIX002", -- too verbose descriptions of todos
                    },
                  },
                },
              },
            },
          })
        end,
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
          lspconfig.lua_ls.setup({})
        end,
      }

      local servers = {
        "slint_lsp",
        "rust_analyzer",
        "cmake",
        "lua_ls",
        "dockerls",
        "basedpyright",
        "ruff",
        "graphql",
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
