local jenkins_config = {
  "ckipp01/nvim-jenkinsfile-linter",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local validate = function()
      require("jenkinsfile_linter").validate()
    end

    local validate_on_save = vim.api.nvim_create_augroup(
      "ValidateOnSave", { clear = false }
    )

    vim.api.nvim_create_user_command("ValidateJenkinsfile", validate, {})
    vim.api.nvim_create_autocmd(
      "BufWritePre", {
        pattern = "Jenkinsfile",
        group = validate_on_save,
        callback = function()
          validate()
        end
      }
    )
  end
}
local is_jenkins_installed = function()
  local success, module_err = pcall(require, "jenkinsfile_linter")
  if success then
    vim.notify("Jenkinsfile linter is installed")
  else
    vim.notify("jenkinsfile linter is not installed")
  end
end

local lsp_functions = require("config.lsp_functions")
local install_jenkins = function()
  if lsp_functions.check_jenkins() then
    return jenkins_config
  else
    return {}
  end
end
return install_jenkins()
