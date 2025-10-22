return {
  {
    "nvim-mini/mini.files",
    commit = "49c8559",
    keys = {
      {
        "<leader>mif",
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
        "<leader>mit",
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
        "<leader>mic",
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
      minifiles.setup()
    end,
  },
  {
    "nvim-mini/mini.pick",
    version = "*",
    config = function()
      local win_config = function()
        local height = math.floor(0.618 * vim.o.lines)
        local width = math.floor(0.618 * vim.o.columns)
        return {
          anchor = "NW",
          height = height,
          width = width,
          row = math.floor(0.5 * (vim.o.lines - height)),
          col = math.floor(0.5 * (vim.o.columns - width)),
        }
      end

      local picker = require("mini.pick")
      picker.setup({
        window = {
          config = win_config
        }
      })

      local split_by_lines = function(text)
        local lines = {}
        for line in string.gmatch(text .. "\n", "(.-)\n") do
          table.insert(lines, line)
        end
        return lines
      end

      local SessionPicker = function()
        local text = vim.fn.system("zoxide query --list")
        local items = split_by_lines(text)
        picker.start({
          source = {
            items = items,
            name = "Change Dir",
            choose = function(chosen_dir)
              vim.cmd("cd " .. chosen_dir)
              vim.print("Changed dir to " .. chosen_dir)
              return false
            end
          }
        })
      end
      vim.api.nvim_create_user_command("SessionPicker", SessionPicker, {})
    end,
  },
  {
    -- https://github.com/nvim-mini/mini.ai
    "nvim-mini/mini.ai",
    commit = "e139eb1",
    config = function()
      require("mini.ai").setup()
    end
  },
  {
    "nvim-mini/mini.sessions",
    config = function()
      local lru_session_path = vim.fn.expand("data") .. "/session/most_recent_session.txt"

      local session_file_exists = function()
        local file = io.open(lru_session_path, "r+")
        -- file isn't there and we can't make it
        if file == nil then
          file = io.open(lru_session_path, "w")
          if file == nil then
            error("Unable to make LRU Session file")
          end
        end
        return file
      end

      require("mini.sessions").setup({
        file = vim.fn.fnamemodify(vim.fn.getcwd() .. ".vim", ":t"),
      })
      local LoadCustomSession = function()
        local cwd = vim.fn.fnamemodify(vim.fn.getcwd() .. ".vim", ":t")
        require("mini.sessions").read(cwd)
        vim.print("Loaded Session :" .. cwd)
      end
      vim.api.nvim_create_user_command("LoadCustomSession", LoadCustomSession, {})
    end,
    keys = {
      {
        "<leader>mis",
        function()
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd() .. ".vim", ":t")
          require("mini.sessions").write(cwd)
        end,
        mode = "n",
        desc = "Save Session"
      },
      {
        "<leader>mil",
        function()
          vim.cmd("SessionPicker")
        end,
        mode = "n",
        desc = "LRU Session Change Dir"
      },
      {
        "<leader>mir",
        function()
          vim.cmd("LoadCustomSession")
        end,
        mode = "n",
        desc = "Load Session"
      },
    },
  },
}
