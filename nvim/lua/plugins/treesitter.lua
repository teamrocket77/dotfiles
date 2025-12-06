-- fmt
return {
  {
    -- dependencies
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    commit = "3ab4f2d2d20be55874e2eb575145c6928d7d7d0e",
    -- cargo install --locked tree-sitter-cli or via npm
    config = function()
      local treesitter = require("nvim-treesitter")
      local ignore_languages = {}
      treesitter.setup({
        ensure_installed = { "markdown", "markdown_line" },
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local kb = 1024
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if not stats then
              vim.print("Unable to get stats")
              vim.print(stats)
              return true
            end
            if ok and stats.size > (kb * 100) then
              return true
            else
              vim.print(lang)
              for _, language in ipairs(ignore_languages) do
                if language == lang then
                  return true
                end
              end
              return false
            end
          end,
        },
      })
      treesitter.install({ "python", "lua", "markdown" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    commit = "ed1cf48d5af252248c55f50b9427e8ce883a2c6b",
    config = function() end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
      local to = require("nvim-treesitter-textobjects")
      to.setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V",  -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = false,
        },
      })
      vim.keymap.set({ "x", "o" }, "af", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
      end)
      -- You can also use captures from other query groups like `locals.scm`
      vim.keymap.set({ "x", "o" }, "as", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
      end)
    end
  }
}
