-- fmt
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
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader><F5>", vim.cmd.UndoTreeToggle)
    end,
  },
  {
    "echasnovski/mini.files",
    version = "*",
    dependencies = {
      "echasnovski/mini.icons",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local minifiles = require("mini.files")
      vim.keymap.set("n", "<leader>mi", function()
        if not minifiles.close() then
          minifiles.open()
        end
      end)

      vim.keymap.set("n", "<leader>mf", function()
        local _ = minifiles.open(vim.api.nvim_buf_get_name(0), false)
        vim.defer_fn(function()
          minifiles.reveal_cwd()
        end, 30)
      end)

      vim.keymap.set("n", "<leader>mo", function()
        if minifiles.get_explorer_state() then
          local fs_data = minifiles.get_fs_entry(0)
          local path = fs_data["path"]
          minifiles.close()
          vim.schedule_wrap(vim.cmd.edit(path))
        else
          print("Must open Minifiles Explorer first")
        end
      end)

      vim.keymap.set("n", "<leader>mt", function()
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
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({})
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    config = function()
      vim.keymap.set("n", "<leader>md", ":MarkdownPreviewToggle<CR>")
    end,
    build = function()
      vim.fn["Lazy load markdown-preview.nvim"]()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>utog", vim.cmd.UndotreeToggle)
      vim.keymap.set("n", "<leader>ushow", vim.cmd.UndotreeToggle)
      function exists(fd)
        local f = io.open(fd, "r")
        if f then
          f:close()
          return true
        end
        return false
      end
      local undo_dir = os.getenv("HOME") .. "/.undodir"
      local e = exists(undo_dir)
      if not e then
        vim.fn.mkdir(undo_dir, "p")
      end
      if e then
        vim.opt.undodir = undo_dir
        vim.opt.undofile = true
      end
    end,
  },
  have_jq(),
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>hadd", function()
        harpoon:list():add()
      end)
      vim.keymap.set("n", "<leader>ht", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():select(1)
      end)
      vim.keymap.set("n", "<leader>hs", function()
        harpoon:list():select(2)
      end)
      vim.keymap.set("n", "<leader>hd", function()
        harpoon:list():select(3)
      end)
      vim.keymap.set("n", "<leader>hf", function()
        harpoon:list():select(4)
      end)
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    {
      "rmagatti/auto-session",
      lazy = false,

      ---enables autocomplete for opts
      ---@module "auto-session"
      ---@type AutoSession.Config
      opts = {
        suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        -- log_level = 'debug',
      },
      config = function()
        require("auto-session").setup({
          lazy_support = true,
        })
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      end,
    },
  },
}
