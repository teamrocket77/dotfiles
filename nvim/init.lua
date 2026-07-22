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
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

require("plugins.default")
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "None" })
-- GitLab CI: treat yaml files with a `ci` path segment (e.g. `.gitlab-ci.yml`,
-- `ci/pipeline.yml`) as `yaml.gitlab` so both gitlab_ci_ls and yamlls attach.
local function yaml_ft(path, _)
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
  }
})
