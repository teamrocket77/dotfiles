return {
  {
    "nvim-mini/mini.files",
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
    -- https://github.com/nvim-mini/mini.ai
    "nvim-mini/mini.ai",
    commit = "e139eb1",
    config = function()
      require("mini.ai").setup()
    end
  }
}
