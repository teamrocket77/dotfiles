ok, error = pcall(require, "dap-python")
print("hi")
if not ok then
  print("python dap isn't installed")
  print(error)
  return
end
local dap = require("dap-python")

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

local getpythonpath = function()
  local cwd = vim.fn.getcwd()
  local py_env = os.getenv("PYTHON_ENV")

  if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
    return cwd .. "/venv/bin/python"
  elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
    return cwd .. "/.venv/bin/python"
  elseif vim.fn.executable(py_env) == 1 then
    return py_env
  elseif vim.fn.executable("/usr/bin/python") == 1 then
    return "/usr/bin/python"
  else
    print("please install a python version")
    return false
  end
end
Python_path = getpythonpath()

if Python_path ~= "" then
  check_package(Python_path)
  dap.setup(Python_path)
end
