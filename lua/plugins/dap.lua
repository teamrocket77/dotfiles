return {
  {
    "mfussenegger/nvim-dap", version = "v3.9.3",
    config = function(cb, config)
      local dap = require("dap")
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or '127.0.0.1'
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
            -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
            type = 'executable',
            command = '/Users/vincentcradler/repos/python/envs/dap-test/bin',
            args = { '-m', 'debugpy.adapter' },
            options = {
              source_filetype = 'python',
            },
          })
        end
      end
    end
  },
  {
    "rcarriga/nvim-dap-ui", dependencies = {
      "mfussenegger/nvim-dap", version = "v3.9.3"
    },
    version = "v3.9.3"
  }
}
