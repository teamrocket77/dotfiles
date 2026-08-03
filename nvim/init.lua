local home = os.getenv("HOME")
local opts = vim.o

vim.g.mapleader = " "

opts.autoindent = true
opts.ignorecase = false
opts.number = true
opts.relativenumber = true
opts.shiftwidth = 4
opts.smartindent = true
opts.smarttab = true
opts.softtabstop = 2
opts.tabstop = 4
opts.wildmenu = true
opts.spell = false
-- vim.opt.sessionoptions = "buffers,curdir,help,resize,tabpages,terminal, winsize,winpos"

vim.cmd([[ set mouse=a ]])

local ignore_list = {
  "node_modules*",
  "*__pycache__/",
  "*pyc*",
  "*venv*",
  "*old_json*",
  "*old_csv*",
}
for _, path in ipairs(ignore_list) do
  vim.opt.wildignore:append(path)
end

vim.opt.path:append("**")
vim.opt.clipboard:append({ "unnamed" })

vim.opt.hlsearch = true
vim.g.doge_enable_mappings = 0
vim.g.python3_host_prog = home .. "/.pyenv/versions/pynvim/bin/python"
-- log level setting

vim.opt.list = true

-- :h option-list
-- :h E355
vim.o.directory = home .. "/.config/nvim/swapfiles/"

vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment number under cursor' })
vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement number under cursor' })

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })

-- Move between diagnostic errors
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

-- Put all project/buffer diagnostics into a list window
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

-- Zoom the current window to "fullscreen" within nvim; toggle to restore splits.
vim.api.nvim_create_user_command("ToggleZoom", function()
  if (vim.g.zoom_status or 0) == 0 then
    vim.cmd("wincmd _ | wincmd |")
    vim.g.zoom_status = 1
  else
    vim.cmd("wincmd =")
    vim.g.zoom_status = 0
  end
end, {})
vim.keymap.set("n", "<leader>0", ":ToggleZoom<CR>", { desc = "Toggle window zoom/fullscreen" })
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

require("plugins.default")
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "None" })
-- True when `path` lives inside a Helm chart (a Chart.yaml sits in some ancestor
-- dir). Used to gate helm filetype detection so unrelated `templates/` dirs
-- (CloudFormation, Ansible, ...) or stray `.tpl` files stay untouched.
local function in_helm_chart(path)
  return path ~= nil and vim.fs.root(path, "Chart.yaml") ~= nil
end

-- GitLab CI: treat yaml files with a `ci` path segment (e.g. `.gitlab-ci.yml`,
-- `ci/pipeline.yml`) as `yaml.gitlab` so both gitlab_ci_ls and yamlls attach.
local function yaml_ft(path, _)
  local name = vim.fs.basename(path):lower()
  -- Helm values overlays (values-prod.yaml, values-staging.yml, ...): tag as
  -- `yaml.helm` so helm_ls attaches for values-schema completion while yamlls
  -- still layers generic YAML validation on top (same trick as gitlab below).
  if name:match("^values%-") then
    return "yaml.helm"
  end
  -- Helm chart templates (e.g. devops/**/templates/*.yaml): these embed Go
  -- template directives ({{ ... }}) and are NOT valid YAML, so hand them to
  -- helm_ls (which lints them) as pure `helm` and keep yamlls away. Gated on a
  -- Chart.yaml ancestor so only real charts are affected.
  if path:match("/templates/") and in_helm_chart(path) then
    return "helm"
  end
  path = path:lower()
  if path:match("[/._-]ci[/._-]") or path:match("gitlab%-ci") then
    return "yaml.gitlab"
  end
  return "yaml"
end

vim.filetype.add({
  filename = {
    envrc = "sh",
    Jenkinsfile = "groovy",
  },
  extension = {
    ["*.Jenkinsfile"] = "groovy",
    ["*.envrc"] = "sh",
    yml = yaml_ft,
    yaml = yaml_ft,
    -- Helm helper templates (_helpers.tpl, etc.) inside a chart -> helm; other
    -- .tpl files fall through to Neovim's default detection.
    tpl = function(path, _)
      return in_helm_chart(path) and "helm" or nil
    end,
  }
})
