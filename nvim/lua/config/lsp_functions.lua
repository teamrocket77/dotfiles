local lsp_functions = {}
local getPlatform = function()
  local system = vim.uv.os_uname().sysname
  if string.lower(system) == "linux" then
    return "linux"
  else
    return "mac"
  end
end

lsp_functions.require_lsp = function()
  local config_path   = vim.fn.stdpath("config")
  local platform_name = getPlatform()
  local lsp_dir       = config_path .. "/lua/" .. platform_name
  vim.print(lsp_dir)
  for _, file in ipairs(vim.fn.readdir(lsp_dir), [[v:val =~ ""]]) do
    local module_name = file:gsub("%.lua$", "")
    require(platform_name .. "." .. module_name)
  end
end


lsp_functions.check_jenkins = function()
  local value = os.getenv("INSTALL_JENKINS_NVIM")
  if value ~= "" then
    return true
  else
    return false
  end
end

lsp_functions.is_jenkins_plugin_installed = function()
  local success, _ = pcall(require, "jenkinsfile_linter")
  if success then
    return true
  else
    return false
  end
end
vim.api.nvim_create_user_command("JenkinsLinterInstalled", lsp_functions.is_jenkins_plugin_installed, {})

return lsp_functions
