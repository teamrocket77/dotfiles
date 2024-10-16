return {
  {
    "mfussenegger/nvim-dap",
    version = "v3.9.3",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
      },
      { "nvim-neotest/nvim-nio" },
      { "mfussenegger/nvim-dap-python" },
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
      -- vim.keymap.set("n", '<leader>c', function() dap.continue() end)
      vim.keymap.set("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end)
      vim.keymap.set("n", "<leader><Right>", function()
        dap.continue()
      end)
      vim.keymap.set("n", "<leader><Up>", function()
        dap.step_over()
      end)
      vim.keymap.set("n", "<leader><Down>", function()
        dap.step_into()
      end)
      vim.keymap.set("n", "<leader><Left>", function()
        dap.step_out()
      end)
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.open()
      end)
      vim.keymap.set("n", "<leader>s<Left>", function()
        dap.repl.open()
      end)

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
      dap.adapters.lldb = {
        type = "executable",
        command = "/opt/homebrew/opt/llvm/bin/lldb-dap", -- required to be absolute path
        name = "lldb",
      }

      -- https://github.com/llvm/llvm-project/blob/main/lldb/tools/lldb-dap/README.md
      local current_dir = "Path to executable: " .. vim.fn.getcwd() .. "/"
      local c_cpp_dap_config = {
        {
          request = "launch",
          name = "launch",
          type = "lldb",
          program = function()
            return vim.fn.input(current_dir)
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.cpp = c_cpp_dap_config
      dap.configurations.c = c_cpp_dap_config
    end,
  },
  {
    "folke/neodev.nvim",
    version = "v2.5.2",
    config = function()
      require("neodev").setup({
        library = {
          plugins = {
            "nvim-dap-ui",
          },
          types = true,
        },
      })
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = { "go", "golang" },
    config = function()
      require("dap-go").setup()
      vim.keymap.set("n", "<leader>ctest", function()
        require("dap-go").debug_test()
      end)
    end,
  },
}
