-- fmt
return {
  {
    "hrsh7th/nvim-cmp",
    commit = "8c82d0b",
    dependencies = {
      { "saadparwaiz1/cmp_luasnip",            commit = "98d9cb5", build = "make install_jsregexp" },
      { "L3MON4D3/LuaSnip",                    commit = "4585605" },
      { "rafamadriz/friendly-snippets",        commit = "572f566" },
      { "hrsh7th/cmp-path",                    commit = "c6635aa" },
      { "hrsh7th/cmp-buffer",                  commit = "b74fab3" },
      { "hrsh7th/cmp-nvim-lua",                commit = "f12408b" },
      { "hrsh7th/cmp-nvim-lsp",                commit = "a8912b8" },
      { "hrsh7th/cmp-nvim-lsp-signature-help", commit = "031e6ba" },
    },
    config = function()
      local cmp = require("cmp")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lsp_signature_help" },
          { name = "path" },
          { name = "nvim_lua" },
        }),
      })
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
