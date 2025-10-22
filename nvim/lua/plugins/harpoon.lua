return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  commit = "ed1f853",
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>hadd", function()
      harpoon:list():add()
    end)
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<leader>hs", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<leader>hd", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<leader>hf", function()
      harpoon:list():select(4)
    end)
  end,
}
