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
  for _, file in ipairs(vim.fn.readdir(lsp_dir), [[v:val =~ ""]]) do
    local module_name = file:gsub("%.lua$", "")
    require(platform_name .. "." .. module_name)
  end
end
return lsp_functions
