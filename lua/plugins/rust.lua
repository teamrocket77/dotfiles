return {
  {
    "mrcjkb/rustaceanvim", version = "4.6.0",
    ft = {'rust'}, config = function()
      vim.keymap.set("n", "<leader>a", function() 
        vim.cmd.RustLsp('codeAction')
      end)
    end
  }
}
