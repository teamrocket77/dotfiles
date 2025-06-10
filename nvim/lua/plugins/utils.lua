-- fmt
-- do we have jq installed?
local have_jq = function()
  if os.execute("jq --help > /dev/null 2>&1") == 0 then
    return { "jrop/jq.nvim" }
  else
    return {}
  end
end

local has_png_paste = function()
  return {
    "epwalsh/obsidian.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    version = "v3.9.0",
    config = function()
      local home = os.getenv("HOME") .. "/vaults/"
      local workspaces = {
        {
          name = "personal",
          path = home .. "personal",
        },
        {
          name = "work",
          path = home .. "work"
        },
      }
      require("obsidian").setup({
        workspaces = workspaces,
        templates = {
          folder = home .. "templates"
        },
      })
      vim.keymap.set("n", "<leader>oct", ":enew | ObsidianTemplate basic-note<CR>")
      vim.opt.conceallevel = 1
      vim.keymap.set("n", "gf", function()
        if require("obsidian").util.cursor_on_markdown_link() then
          return "<cmd>ObsidianFollowLink<CR>"
        else
          return "gf"
        end
      end, { noremap = false, expr = true })
    end
  }
end

return {
  {
    "echasnovski/mini.files",
    commit = "49c8559",
    keys = {
      {
        "<leader>mt",
        function()
          local mini = require("mini.files")
          if not mini.close() then
            mini.open()
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle"
      },
      {
        "<leader>mf",
        function()
          local mini = require("mini.files")
          if not mini.close() then
            mini.open()
            vim.defer_fn(function()
              mini.reveal_cwd()
            end, 30)
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle"
      }
    },
    config = function()
      local minifiles = require("mini.files")
      minifiles.setup({})
    end,
  },
  {
    "kwkarlwang/bufresize.nvim",
    commit = "3b19527",
    lazy = true,
    config = function()
      local opts = { noremap = true, silent = true }
      require("bufresize").setup({
        register = {
          keys = {
            { "n", "<leader>w<", "30<C-w><",     opts },
            { "n", "<leader>w>", "30<C-w>>",     opts },
            { "n", "<leader>w+", "10<C-w>+",     opts },
            { "n", "<leader>w-", "10<C-w>-",     opts },
            { "n", "<leader>w_", "<C-w>_",       opts },
            { "n", "<leader>w=", "<C-w>=",       opts },
            { "n", "<leader>w|", "<C-w>|",       opts },
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
    commit = "586e87f",
    config = function()
      require("tint").setup({
        tint = -20,
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
    "sindrets/diffview.nvim",
    commit = "4516612",
    config = function()
      require("diffview").setup({
        hooks = {
          diff_read_buf = function(bufnr)
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.colorcolumn = false
          end,
        }
      })
    end,
  },
  {
    "mbbill/undotree",
    commit = "b951b87",
    config = function()
      vim.keymap.set("n", "<leader>utog", vim.cmd.UndotreeToggle)
      vim.keymap.set("n", "<leader>ushow", vim.cmd.UndotreeToggle)
      local exists = function(fd)
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
  have_jq(), has_png_paste(),
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    commit = "ed1f853",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>hadd", function()
        harpoon:list():add()
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
    commit = "1edad11",
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    commit = "a94fc68",
    config = function()
      local lualine = require("lualine")
      local function session_name()
        return require("possession.session").get_session_name() or ""
      end
      lualine.setup({
        sections = {
          lualine_a = { "filename" },
          lualine_c = {},
          lualine_x = { "encoding", "searchcount", "filetype" },
          lualine_y = { session_name }
        },
      })
    end
  },
  {
    "goolord/alpha-nvim",
    commit = "a35468c",
    config = function()
      local alpha = require "alpha"
      local session_dir = os.getenv("HOME") .. "/.config/nvim/sessions/"
      local most_recent_session = session_dir .. "recent-session.txt"
      local file_lines = {}
      local lsp_functions = require("config.functions")

      local file = io.open(most_recent_session, "r")

      local last_five_sessions = function()
        local exists = lsp_functions.does_session_file_exist()
        if exists == true then
          file = io.open(most_recent_session, "r")
          for line in file:lines() do
            table.insert(file_lines, line)
          end
          file:close()
          return { unpack(file_lines, math.max(#file_lines - 4, 1), #file_lines) }
        else
          return {}
        end
      end
      vim.schedule_wrap(vim.print(file_lines))
      local start_val = 0
      local dashboard = require "alpha.themes.dashboard"
      dashboard.section.buttons.val = {
        dashboard.button("e", "New file", ":ene<BAR> startinsert <CR>"),
        dashboard.button("g", " " .. " Find Text", ":Telescope live_grep <CR>"),
        dashboard.button("f", " " .. " Find Files", ":Telescope find_files <CR>"),
        dashboard.button("z", " " .. " Find Files FZF", ":FZF <CR>"),
        dashboard.button("c", " " .. " Nvim Config", [[<cmd>PossessionLoad ~/.config<CR>]]),
        dashboard.button("l", "" .. " Lazy", ":Lazy<CR>"),
        (function()
          local group = { type = "group", opts = { spacing = 1 } }
          group.val = {
            { type = "text", val = "Last 5 Sessions", opts = { position = "center" } }
          }
          local last_sessions = last_five_sessions()
          for i, session in pairs(last_sessions) do
            local button = dashboard.button(tostring(i), "勒 " .. session,
              "<cmd>PossessionLoad " .. session .. "<cr>")
            table.insert(group.val, button)
          end
          start_val = start_val + #last_sessions
          return group
        end)(),
        (function()
          local group = { type = "group", opts = { spacing = 1 } }
          group.val = {
            { type = "text", val = "Previous Sessions", opts = { position = "center" } }
          }
          for i, session in pairs(require("possession.query").as_list()) do
            local button = dashboard.button(tostring(i + start_val), "勒 " .. session.name,
              "<cmd>PossessionLoad " .. session.name .. "<cr>")
            table.insert(group.val, button)
          end
          return group
        end)(),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.config)
    end
  },
  {
    "jedrzejboczar/possession.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    commit = "8fb21fa",
    config = function()
      local session_dir = os.getenv("HOME") .. "/.config/nvim/sessions/"
      local most_recent_session = session_dir .. "recent-session.txt"
      local max_line_length = 5
      require("possession").setup({
        session_dir = session_dir,
        autosave = {
          current = function(name)
            if name == "~" then
              return false
            end
            return true
          end,
          cwd = true,
          on_quit = true
        },
        hooks = {
          after_save = function(name)
            local line_count = 0
            local file_lines = {}
            local current_obj_val = -1
            local file = io.open(most_recent_session, "r+")
            -- file isn't there and we can't make it
            if file == nil then
              file = io.open(most_recent_session, "w")
              if file == nil then
                return
              end
            end

            for line in file:lines() do
              table.insert(file_lines, line)
              line_count = line_count + 1
              if line == name then
                current_obj_val = line_count
              end
            end

            if current_obj_val > 0 then
              table.remove(file_lines, current_obj_val)
            else
              if line_count >= max_line_length then
                table.remove(file_lines, max_line_length)
              end
              table.insert(file_lines, 1, name)

              local file_seek = file:seek("set")
              if file_seek ~= 0 then
                vim.schedule_wrap(vim.print("Unable to restore seek position to byte 0, got " .. tostring(file_seek)))
              end

              for i, line in ipairs(file_lines) do
                if i >= max_line_length then
                  break
                end
                vim.schedule_wrap(vim.print(line))
                file:write(line .. "\n")
              end
              file:close()
            end
          end
        },
        commands = {
          save = "SSave",
          load = "SLoad",
          delete = "SDelete",
          list = "SList",
        },
      })
    end
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.3,
      cursor_color = "#ff8800",
      trailing_exponent = 7,
      hide_target_hack = true,
      gamma = 1,
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    version = "v2.1.0",
    commit = "3c94266",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
}
