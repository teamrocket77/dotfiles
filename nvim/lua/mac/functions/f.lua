-- fmt
local lsp_functions = {}
local lspconfig = require("lspconfig")

lsp_functions.have_ghcup_ls_inherent = function()
  if os.execute("ghcup -h > /dev/null 2>&1") == 0 then
    vim.lsp.enable("hls")
  end
end
lsp_functions.have_ghcup_ls = function(t)
  if os.execute("ghcup -h > /dev/null 2>&1") == 0 then
    t["hls"] = function()
      lspconfig.hls.setup({})
    end
  end
end

lsp_functions.have_go_ls = function()
  if os.execute("go version > /dev/null 2>&1") == 0 then
    return function()
      vim.lsp.gopls.setup({})
    end
  else
    return nil
  end
end

lsp_functions.have_go_ls_install = function()
  if os.execute("go version > /dev/null 2>&1") == 0 then
    return "gopls"
  else
    return nil
  end
end

lsp_functions.have_ghcup_ls_install = function()
  if os.execute("ghcup -h > /dev/null 2>&1") == 0 then
    return "hls"
  else
    return ""
  end
end

vim.lsp.config("hls", {
  filetypes = { "haskell", "lhaskell", "cabal" },
})

lsp_functions.have_ghcup_ls_inherent()

return lsp_functions
