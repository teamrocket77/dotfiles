local check_package = function(executable)
  local python_script = [[
import importlib.util
if importlib.util.find_spec('debugpy'):
  exit()
exit(1)]]
  local temp_file = "/tmp/tmp.py"
  local file = io.open(temp_file, "w")
  if file == nil then
    print("Unable to write to /tmp for testing python packages")
    return
  end

  file:write(python_script)
  file:close()

  vim.fn.jobstart({ executable, temp_file }, {

    on_stdout = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
    on_stderr = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
    on_exit = function(_, code)
      if tostring(code) == "1" then
        print(
          "Script exited with code",
          code,
          "Which could means that debugpy isn't installed"
        )
      end
      -- Clean up the temporary file
      os.remove(temp_file)
    end,
  })
end

local get_python_path = function()
  local cwd = vim.fn.getcwd()
  local py_env = os.getenv("PYTHON_ENV")

  if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
    return cwd .. "/venv/bin/python"
  elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
    return cwd .. "/.venv/bin/python"
  elseif vim.fn.executable("/usr/bin/python") == 1 then
    return "/usr/bin/python"
  elseif py_env ~= nil and vim.fn.executable(py_env) == 1 then
    return py_env
  else
    print("Please install a python version to use DAP")
    return false
  end
end
PyPath = get_python_path()

if PyPath then
  -- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
  -- untested
  -- check_package(Python_path)
  local dap = require("dap")
  dap.adapters.python = function(cb, config)
    local default_table = {
      options = { source_filetype = "python" }
    }
    if config.request == "attach" then
      local port = (config.connect or config).port
      local host = (config.connect or config).host or "127.0.0.1"
      local merged = vim.tbl_deep_extend("keep", default_table, {
        type = "server",
        port = assert(port, "`connect.port` is required for a python `attach` configuration"),
        host = host,
      })
    else
      -- always required no matter the server
      local merged = vim.tbl_deep_extend("keep", {
        type = "executable",
        command = PyPath,
        args = { "-m", "debugpy.adapter" },
      })
    end
    cb(merged)
  end
  dap.configurations.python = {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
  }
end
