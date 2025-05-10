-- fmt
return {
  {
    -- https://github.com/olimorris/codecompanion.nvim
    "olimorris/codecompanion.nvim",
    version = "v14.9.1",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      "j-hui/fidget.nvim",
      "OXY2DEV/markview.nvim",
    },
    config = function()
      local codecompanion = require("codecompanion")
      codecompanion.setup({
        log_level = "DEBUG",
        strategies = {
          chat = { adapter = "gemini_2_5" },
          inline = { adapter = "gemini_2_5" },
        },
        adapters = {
          claude_3_7 = require("codecompanion.adapters").extend("openai_compatible", {
            name = "claude_3_7",
            env = {
              chat_url = "chat/completions",
              models_endpoint = "models",
              url = "http://localhost:3000/api/",
              api_key = os.getenv("OPENAI_API_KEY"),
            },
            schema = {
              model = {
                default = "sonnet37.claude-3-7-sonnet@20250219",
              },
            },
            opts = { allow_insecure = true },
          }),
          gemini_2_5 = require("codecompanion.adapters").extend("openai_compatible", {
            name = "Gemini_2.5",
            env = {
              chat_url = "chat/completions",
              models_endpoint = "models",
              url = "http://localhost:3000/api/",
              api_key = os.getenv("OPENAI_API_KEY"),
            },
            schema = {
              model = {
                default = "gemini_25_exp.gemini-2.5-pro-preview-03-25",
              },
            },
            opts = { allow_insecure = true },
          }),
        },
      })
      vim.keymap.set("n", "<Leader>cc", function()
        codecompanion.toggle()
      end, { noremap = true, silent = true })
      require("ai.custom.util"):init()
    end,
  },
}
