local inlay_hint_servers = {
  lua_ls = true,
  basedpyright = true,
}

local formatting_options = {
  python = "ruff"
}

servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "hls",
  "terraformls"
}

for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end
