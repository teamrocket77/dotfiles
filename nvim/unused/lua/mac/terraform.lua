vim.lsp.config("terraformls", {
  settings = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    { experimental = { telementryVersion = 0 } }
  ),
})
