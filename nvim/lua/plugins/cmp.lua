return {
  {
    "hrsh7th/nvim-cmp",
    commit = "8c82d0b",
    dependencies = {
      { "saadparwaiz1/cmp_luasnip",            commit = "98d9cb5" },
      { "L3MON4D3/LuaSnip",                    commit = "4585605" },
      { "rafamadriz/friendly-snippets",        commit = "572f566" },
      { "hrsh7th/cmp-cmdline",                 commit = "d126061" },
      { "hrsh7th/cmp-path",                    commit = "c6635aa" },
      { "hrsh7th/cmp-buffer",                  commit = "b74fab3" },
      { "hrsh7th/cmp-nvim-lua",                commit = "f12408b" },
      { "hrsh7th/cmp-nvim-lsp",                commit = "a8912b8" },
      { "hrsh7th/cmp-nvim-lsp-signature-help", commit = "031e6ba" },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

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
    end,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        {
          name = "lazydev",
          group_index = 0,
        },
      })
    end,
  },
  { "justinsgithub/wezterm-types", commit = "1518752", lazy = true, ft = { "lua" } },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    commit = "f59bd14",
    dependencies = { { "justinsgithub/wezterm-types" } },
    opts = {
      library = {
        "lazy.nvim",
        { path = "wezterm-types", mods = { "wezterm" } },
      }
    },
  },
}
