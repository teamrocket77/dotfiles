vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

-- :HelmT / <leader>hr — render THIS template buffer and validate it against its
-- CRD schema. All the work lives in lua/plugins/helm-render.lua (shared with the
-- global :HelmPick); here we just bind the buffer-local, current-template entry.
local helm = require("plugins.helm-render")
vim.api.nvim_buf_create_user_command(0, "HelmT", function()
  helm.render_current()
end, { desc = "Render the current Helm template (--show-only) and validate it against its CRD schema" })
vim.keymap.set("n", "<leader>hr", function()
  helm.render_current()
end, { buffer = 0, desc = "HelmT: render + validate this template" })
