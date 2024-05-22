return {
  "OmniSharp/omnisharp-vim",
  config = function()
    vim.g.OmniSharp_server_use_net6 = 1
    vim.g.OmniSharp_server_stdio = 1
    vim.g.OmniSharp_server_use_mono = 1
  end
}
