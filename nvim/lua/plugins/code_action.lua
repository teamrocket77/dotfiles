return {
  "rachartier/tiny-code-action.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "folke/snacks.nvim", opts = { terminal = {} } },
  },
  event = "LspAttach",
  opts = {
    picker = "snacks",
  },
  config = function()
    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
      require("tiny-code-action").code_action()
    end, { noremap = true, silent = true })
    local ft_ext = vim.fn.expand("%:e")
    if ft_ext ~= "scpt" then
      require("tiny-code-action").code_action({})
    end
  end,
}
