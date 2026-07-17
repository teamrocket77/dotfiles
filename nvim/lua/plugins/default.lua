require("plugins.dap")
require("plugins.trouble")
require("plugins.mini")
require("plugins.conform")
require("plugins.folke_utils")
require("plugins.treesitter")

local s = {}
s.servers = {
  "cmake",
  "lua_ls",
  "dockerls",
  "basedpyright",
  "ruff",
  "terraformls",
  "yamlls",
  "gitlab_ci_ls",
  "bashls",
}

require("plugins.cmp")
require("plugins.mason").setup(s)
require("plugins.undotree")


