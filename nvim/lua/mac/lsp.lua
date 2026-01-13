local functions = require("config.functions")
local get_cmp = function()
  local ok, module = pcall(require, "cmp_nvim_lsp")
  if not ok then
    return nil
  end
  return module.default_capabilities()
end

vim.lsp.config("*", {
  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr) end,

  capabilities = get_cmp(),
  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_init = function(client, bufnr)
    local settings = {
      buffer = 0,
      id = client.id,
    }
    local ft = vim.bo.filetype
    if client:supports_method("textDocument/inlayHints") and functions.inlay_hint_servers[client.name] == nil then
      print("Hinting is supported for this server it should be enabled")
    end
    local opts = { buffer = 0 }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>dline", function()
      local underline = vim.diagnostic.config().underline
      vim.diagnostic.config({ underline = not underline })
    end, opts)
  end,
})

vim.diagnostic.config({
  underline = false,
  virtual_text = {
    severity = {
      vim.diagnostic.severity.ERROR,
    },
    prefix = "<",
    suffix = ">",
    source = true,
  },
  -- update_in_insert = true,
  severity_sort = true,
  float = {
    source = true,
  },
})

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = 1 })
end)

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = 1 })
end)

vim.keymap.set("n", "<C-j>", function()
  vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = 1, float = 1 })
end)

vim.keymap.set("n", "<C-k>", function()
  vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = -1, float = 1 })
end)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>flt", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>buf", functions.get_lsp)
vim.keymap.set("n", "<leader>thi", functions.toggle_hints)

for _, server in ipairs(functions.servers) do
  vim.lsp.enable(server)
end
vim.lsp.enable("sourcekit")
