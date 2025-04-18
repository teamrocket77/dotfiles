-- fmt
return {
  {
    -- https://github.com/olimorris/codecompanion.nvim
    "olimorris/codecompanion.nvim",
    version = "v14.9.1",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    config = function()
      local codecompanion = require("codecompanion")
      codecompanion.setup({
        log_level = "DEBUG",
        strategies = {
          chat = { adapter = "gemini_2_5" },
          inline = { adapter = "gemini_2_5" },
        },
        prompt_libary = {
          ["introduction"] = {
            strategy = "chat",
            opts = {
              short_name = "intro",
            },
            prompts = {
              role = "user",
              content = [[How are you ]],
            },
          },
        },
        adapters = {
          gemini_2_5 = require("codecompanion.adapters").extend("openai_compatible", {
            name = "Gemini_2.5",
            env = {
              chat_url = "chat/completions",
              models_endpoint = "models",
              url = "http://localhost:3000/api/",
              api_key = os.getenv("OPEN_WEBUI_API_KEY"),
            },
            schema = {
              model = {
                default = "flash_25.gemini-2.5-pro-preview-03-25",
              },
            },
            opts = { allow_insecure = true },
          }),
        },
      })
      vim.keymap.set("n", "<Leader>chat", function()
        codecompanion.toggle()
      end, { noremap = true, silent = true })
    end,
  },
}
