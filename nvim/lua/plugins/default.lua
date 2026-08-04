require("plugins.dap")
require("plugins.trouble")
require("plugins.mini")
require("plugins.conform")
require("plugins.folke_utils")
require("plugins.treesitter")
require("plugins.markview")

local s = {}
s.servers = {
  "cmake",
  "lua_ls",
  "dockerls",
  "basedpyright",
  "ruff",
  "terraformls",
  "terragrunt_ls",
  "yamlls",
  "gitlab_ci_ls",
  "helm_ls",
  "bashls",
}

require("plugins.cmp")
require("plugins.mason").setup(s)
require("plugins.undotree")


