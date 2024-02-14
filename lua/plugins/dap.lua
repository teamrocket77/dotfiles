return {
  {
    "mfussenegger/nvim-dap", version = "v3.9.3",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
      },
    },
    config = function(cb, configuration)
      local dap = require("dap")
      local dapui = require("dapui")
      -- dap.listeners.before.attach.dapui_config = function()
      --   dapui.open()
      -- end
      -- dap.listeners.before.launch.dapui_config = function()
      --   dapui.open()
      -- end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      --   dapui.close()
      -- end
      vim.keymap.set("n", '<leader>c', function() dap.continue() end)
      vim.keymap.set("n", '<leader>b', function() dap.toggle_breakpoint() end)
      local getpythonpath = function()
        local cwd = vim.fn.getcwd()
        local env = os.getenv("VIRTUAL_ENV")
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          print("running first option now")
          return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          print("running second option now")
          return cwd .. '/.venv/bin/python'
        elseif env then
          return env .. '/venv/bin/python'
        elseif vim.fn.executable('/usr/bin/python') == 1 then
          return '/usr/bin/python'
        else
          print("please install a python version")
          print("We are currently checking /usr/bin/python and no executable has been found")
          return '/usr/bin/python'
        end
      end
      local pythonpath = getpythonpath()
      dap.adapters.python = function(cb, configuration)
        if configuration.request == 'attach' then
          ---@diagnostic disable-next-line: undefined-field
          local port = (configuration.connect or config).port
          ---@diagnostic disable-next-line: undefined-field
          local host = (configuration.connect or config).host or '127.0.0.1'
          cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
              source_filetype = 'python',
            },
          })
        else
          cb({
            type = 'executable',
            command = pythonpath,
            args = { '-m', 'debugpy.adapter' },
            options = {
              source_filetype = 'python',
            },
          })
        end
      end
      dap.configurations.python = {
        {
          type = 'python';
          request = 'launch';
          name = "launch file";
          program = "${file}";
          pythonpath = pythonpath;
        },
      }

      dapui.setup()
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
    end
  },
  {
  "folke/neodev.nvim", version = "v2.5.2",
  config = function()
    require("neodev").setup({
      library = {
        plugins = {
          "nvim-dap-ui"
        },
        types = true
      }
    })
  end
  }
}
