return {
  {
    'hrsh7th/nvim-cmp', version = "v0.0.1",
    dependencies = {
      {'L3MON4D3/LuaSnip'},
      {'saadparwaiz1/cmp_luasnip'},
      {'rafamadriz/friendly-snippets'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-nvim-lua'},
      {'hrsh7th/cmp-nvim-lsp'},
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({select = true}),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lsp_signature_help" },
          { name = "path" },
          { name = "nvim_lua" },
        })
      })
    end,
  },
}
