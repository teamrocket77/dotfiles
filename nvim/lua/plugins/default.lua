require("plugins.dap")
require("plugins.trouble")
require("plugins.mini")
require("plugins.conform")
require("plugins.folke_utils")
require("plugins.treesitter")
require("plugins.markview")
require("plugins.kitty-scrollback")
require("plugins.git-blame")

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

-- Nix machine only (signalled by $NIX_PROFILES, same as shell/env.sh): pull in
-- the nix LSP so mason installs/enables it there but never on the work box.
if (vim.env.NIX_PROFILES or "") ~= "" then
  table.insert(s.servers, "nixd")
end

require("plugins.cmp")
require("plugins.mason").setup(s)
require("plugins.undotree")

vim.schedule(function() require("checks").notify() end)


