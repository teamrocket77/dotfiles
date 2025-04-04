-- do we have jq installed?
local have_jq = function()
  if os.execute("jq --help > /dev/null 2>&1") == 0 then
    return { "jrop/jq.nvim" }
  else
    return {}
  end
end

return {
	{
		-- "github/copilot.vim"
	},
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader><F5>", vim.cmd.UndoTreeToggle)
    end,
  },
  {
    "echasnovski/mini.nvim",
    version = "*",
    dependencies = {
      "echasnovski/mini.icons",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local minifiles = require("mini.files")
      vim.keymap.set("n", "<leader>mif", function()
        if not minifiles.close() then
          minifiles.open()
        end
      end)
      minifiles.setup({})
    end,
  },
  {
    "kwkarlwang/bufresize.nvim",
    config = function()
      local opts = { noremap = true, silent = true }
      require("bufresize").setup({
        register = {
          keys = {
            { "n", "<leader>w<", "30<C-w><", opts },
            { "n", "<leader>w>", "30<C-w>>", opts },
            { "n", "<leader>w+", "10<C-w>+", opts },
            { "n", "<leader>w-", "10<C-w>-", opts },
            { "n", "<leader>w_", "<C-w>_", opts },
            { "n", "<leader>w=", "<C-w>=", opts },
            { "n", "<leader>w|", "<C-w>|", opts },
            { "n", "<leader>wo", "<C-w>|<C-w>_", opts },
          },
          trigger_events = { "BufWinEnter", "WinEnter" },
        },
        resize = {
          keys = {},
          trigger_events = { "VimResized" },
          increment = 5,
        },
      })
    end,
  },
  {
    "levouh/tint.nvim",
    config = function()
      require("tint").setup({
        -- tint = -70,
      })
    end,
  },
  {
    "kkoomen/vim-doge",
    build = ":call doge#install()",
    config = function()
      vim.keymap.set("n", "<Leader>doc", "<Plug>(doge-generate)")
      vim.keymap.set("n", "<Leader>ton", "<Plug>(doge-comment-jump-forward)")
      vim.keymap.set("n", "<Leader>toN>", "<Plug>(doge-comment-jump-backward)")
      -- vim.g.doge_enable_mappings = 0
    end,
    ft = { "Python" },
  },
  {
    "tpope/vim-obsession",
  },
  {
	  "sindrets/diffview.nvim", config = function()
		  require('diffview').setup({
		  })
	  end
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    config = function()
      vim.keymap.set("n", "<leader>md", ":MarkdownPreviewToggle<CR>")
    end,
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
	'mbbill/undotree', config = function()
		vim.keymap.set('n', '<leader>utog', vim.cmd.UndotreeToggle)
		vim.keymap.set('n', '<leader>ushow', vim.cmd.UndotreeToggle)
	end
  },
  have_jq(),
}
