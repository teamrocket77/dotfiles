return {
  {
    "nvim-mini/mini.extra",
    version = false,
  },
  {
    "nvim-mini/mini.files",
    dependencies = {
      { "nvim-mini/mini.extra" },
    },
    commit = "49c8559",
    keys = {
      {
        "<leader>mit",
        function()
          local mini = require("mini.files")
          if not mini.close() then
            mini.open(nil, true)
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle",
      },
      {
        "<leader>mif",
        function()
          local mini = require("mini.files")
          if not mini.close() then
            mini.open(vim.api.nvim_buf_get_name(0))
          end
        end,
        mode = "n",
        desc = "Mini Files Toggle",
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
        desc = "Mini Files Toggle CWD",
      },
    },
    config = function()
      local minifiles = require("mini.files")
      minifiles.setup({
        options = {
          permanent_delete = false,
        },
      })
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
          config = win_config,
        },
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
            end,
          },
        })
      end
      vim.api.nvim_create_user_command("SessionPicker", SessionPicker, {})
    end,
  },
  {
    "nvim-mini/mini.sessions",
    config = function()
      local lru_session_path = vim.fn.expand("data") .. "/session/most_recent_session.txt"

      require("mini.sessions").setup({})
    end,
    keys = {
      {
        "<leader>mis",
        function()
          require("mini.sessions").write("Session.vim")
        end,
        mode = "n",
        desc = "Save Session",
      },
      {
        "<leader>mil",
        function()
          vim.cmd("SessionPicker")
        end,
        mode = "n",
        desc = "LRU Session Change Dir",
      },
      {
        "<leader>mir",
        function()
          require("mini.sessions").read("Session.vim")
        end,
        mode = "n",
        desc = "Load Session",
      },
    },
  },
}
