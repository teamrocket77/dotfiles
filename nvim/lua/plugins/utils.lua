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
            mini.open(nil, true)
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
            mini.open(vim.api.nvim_buf_get_name(0))
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle"
      },
      {
        "<leader>mc",
        function()
          local mini = require("mini.files")
          local last_path = mini.get_latest_path()
          if not mini.close() then
            if last_path == nil then
              mini.open(last_path)
            else
              mini.open(vim.api.nvim_buf_get_name(0))
            end
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle CWD"
      }
    },
    config = function()
      local minifiles = require("mini.files")
      minifiles.setup({})
    end,
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/snacks.nvim",
    commit = "5eac729",
    priority = 1000,
    lazy = false,
    opts = {
      lazygit = { enabled = true },
      rename = { enabled = true },
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 5, pane = 2 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2, pane = 2, limit = 5 },
          { section = "startup" },
        },
        preset = {
          keys = {
            { key = "e", icon = "", desc = "New file", action = ":ene | startinsert" },
            { key = "g", icon = " ", desc = "Find Text", action = function() require("snacks").picker.grep() end },
            { key = "f", icon = " ", desc = "Find Files", action = function() require("snacks").picker.files() end },
            { key = "c", icon = " ", desc = "Edit NVIM Config", action = ":PossessionLoad ~/.config" },
            { key = "r", icon = " ", desc = "Edit Zsh file", action = ":e ~/.zshrc" },
            { key = "l", icon = "󰒲", desc = "Lazy", action = ":Lazy" },
            function()
              local home = os.getenv("HOME")
              local cur_dir = vim.fn.getcwd()
              local possession = require("possession.session")
              local found = false
              local list = possession.list()
              local val = ""
              for k, _ in pairs(list) do
                val = list[k]["name"]
                val = val:gsub("~", home)
                if val == cur_dir then
                  found = true
                  break
                end
              end
              if found then
                return {
                  key = "z",
                  desc = "Load CWD session ",
                  action = ":PossessionLoad " ..
                      cur_dir:gsub(home, "~"),
                  indent = 2
                }
              end
              return {}
            end,
          },
        }
      },
      indent = {
        enabled = true,
      },
      scope = { enabled = true, },
      notifier = {
        enabled = true,
        timeout = 1000
      },
    },
    keys = {
      { "<leader><space>", function() require("snacks").picker.smart() end,            desc = "Opens Snacks Picker" },
      { "<leader>gf",      function() require("snacks").picker.grep() end,             desc = "Grep" },
      { "<leader>ff",      function() require("snacks").picker.files() end,            desc = "Find Files" },
      { "<leader>gb",      function() require("snacks").picker.grep_buffers() end,     desc = "Grep Buffers" },
      { "gd",              function() require("snacks").picker.lsp_definitions() end,  desc = "LSP Definition" },
      { "gD",              function() require("snacks").picker.lsp_declarations() end, desc = "LSP Declerations" },
      {
        "<leader>gp",
        function()
          local items               = {}
          local possession          = require("possession")
          local possession_sessions = possession.list()
          local longest_name        = 0
          local idx                 = 1
          local name                = ""
          for k, v in pairs(possession_sessions) do
            local name = possession_sessions[k]["name"]
            table.insert(items, {
              idx = idx,
              score = idx,
              text = name,
              name = name,
            })
            longest_name = math.max(longest_name, string.len(name))
            idx = idx + 1
          end
          vim.print(vim.inspect(items))
          local snacks = require("snacks")
          snacks.picker({
            items = items,
            format = function(item)
              local ret = {}
              ret[#ret + 1] = { ("%-" .. longest_name .. "s"):format(item.name), "SnacksPickerLabel" }
              ret[#ret + 1] = { item.text, "SnacksPickerComment" }
              return ret
            end,
            confirm = function(picker, item)
              picker:close()
              vim.cmd(("PossessionLoad %s"):format(item.name))
            end,
          })
        end,
        desc = "Session Picker"
      },
      { "<leader>gls", function() require("snacks").picker.lsp_symbols() end,           desc = "LSP Symbols" },
      { "<leader>gws", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Symbols for Workspace" },
      { "<leader>ql",  function() require("snacks").picker.qflist() end,                desc = "Quickfix List open" },
    },
    init = function()
      local Snacks = require("snacks")
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd
          Snacks.toggle.treesitter():map("<leader>uT")
        end
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
      vim.api.nvim_create_user_command("ObjInspector", function()
        vim.api.nvim_feedkeys(':lua require("snacks").notify(vim.inspect(x), {timeout = 0, ft="y"})', "n", false)
        -- currently cannot pass tables
      end, { desc = "Writes most of the stuff required for the vim inspect to work with snacks" })

      Snacks.setup({})
    end
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
          diff_read_buf = function(_)
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
            local home = os.getenv("HOME")
            if name == "~" or name == home then
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
      vim.api.nvim_set_keymap("n", "<C-s>", ":PossessionSaveCwd<CR>", { noremap = true, silent = true })
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
