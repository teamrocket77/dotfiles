local has_png_paste = function()
  return {
    "epwalsh/obsidian.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    version = "v3.9.0",
    config = function()
      local home = os.getenv("HOME") .. "/vaults/"
      local workspaces = {
        {
          name = "personal",
          path = home .. "personal",
        },
        {
          name = "work",
          path = home .. "work"
        },
      }
      require("obsidian").setup({
        workspaces = workspaces,
        templates = {
          folder = home .. "templates"
        },
      })
      vim.keymap.set("n", "<leader>oct", ":enew | ObsidianTemplate basic-note<CR>")
      vim.opt.conceallevel = 1
      vim.keymap.set("n", "gf", function()
        if require("obsidian").util.cursor_on_markdown_link() then
          return "<cmd>ObsidianFollowLink<CR>"
        else
          return "gf"
        end
      end, { noremap = false, expr = true })
    end
  }
end

return has_png_paste()
