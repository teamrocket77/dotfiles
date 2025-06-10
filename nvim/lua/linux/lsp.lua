require("constants")
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        init_options = {
          settings = {
            args = {},
            cmd = (function()
              if IsPynvim() then
                return { vim.g.python3_host_prog, "-m", "ruff-lsp" }
              else
                return { "ruff_lsp" }
              end
            end)(),
          },
        },
      })

      lspconfig.pyright.setup({
        settings = {
          pyrght = {},
          python = {
            analysis = {},
          },
        },
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
      })

      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd-18",
        },
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    commit = "7f265cd",
    dependencies = {
      { "mason-org/mason-lspconfig.nvim", commit = "5477d67" },
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "wesleimp/stylua.nvim" },
    },

    config = function()
      function Get_lsp()
        local clients = vim.lsp.get_clients()
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

      local formatters = {
        lua = "stylua",
        -- c = "clang-format-18",
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
        callback = function(ev)
          local opts = { buffer = ev.buf }
          local cursor_position = vim.api.nvim_win_get_cursor(0)
          format_buffer()
          vim.api.nvim_win_set_cursor(0, cursor_position)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "g=", format_buffer, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })

      -- currently managed by ASDF

      local linters = {
        "pylint",
        "asm-lsp",
        "yamllint",
      }
      local servers = {
        -- "cmake",
        "lua_ls",
        "dockerls",
        -- "pyright",
        -- "ruff_lsp",
        "graphql",
        -- "tsserver",
        "terraformls",
        "yamlls",
      }
      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")
      mason.setup()
      mason_lsp.setup({
        automatic_installation = true,
        ensure_installed = servers,
        -- handlers = handlers,
      })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
      vim.keymap.set("n", "<leader>flt", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>buf", Get_lsp)
    end,
  },
}
