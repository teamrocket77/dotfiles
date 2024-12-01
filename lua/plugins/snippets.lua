return {
  "L3MON4D3/LuaSnip",
  dependencies = { "honza/vim-snippets" },
  config = function(opts)
    local home = os.getenv("HOME")
    local types = require("luasnip.util.types")
    local luasnip = require("luasnip")
    luasnip.config.setup({
      link_roots = true,
      keep_roots = true,
      link_children = true,
      ext_opts = {
        [types.choiceNode] = {
          active = {
            virt_text = { { "<-", "Error" } },
          },
        },
      },
    })

    require("luasnip.loaders.from_snipmate").load({
      paths = {
        home .. "/.config/nvim/lua/snippets",
      },
    })

	for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/luasnippets/*lua", true)) do
		loadfile(ft_path)()
	end
    -- require("luasnip.loaders.from_lua").load({
    --   paths = {
    --     home .. "/.config/nvim/lua/luasnippets/",
    --   },
    -- })

    vim.api.nvim_set_keymap(
      "i",
      "<C-u>",
      '<cmd>lua require("luasnip.extras.select_choice")()<CR>',
      { noremap = true, silent = true }
    )

    vim.keymap.set({ "s", "i" }, "<c-j>", function()
      if luasnip.expand_or_jumpable(1) then
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          luasnip.expand(1)
        end
      end
    end, { silent = true })

    vim.keymap.set({ "s", "i" }, "<c-k>", function()
      if luasnip.expand_or_jumpable(-1) then
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          luasnip.expand(-1)
        end
      end
    end, { silent = true })

    vim.keymap.set({ "s", "i" }, "<c-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
		elseif luasnip.in_snippet() then
			luasnip.activate_node()
      end
    end, { silent = true })

    vim.keymap.set(
      "n",
      "<leader><leader>s",
      "<CMD>source ~/.config/nvim/lua/plugins/snippets.lua<CR>"
    )
  end,
}
