return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  commit = "a94fc68",
  config = function()
    local lualine = require("lualine")
    local auto_theme_custom = require("lualine.themes.auto")
    local colors = {
      black        = "#282828",
      white        = "#ebdbb2",
      red          = "#fb4934",
      green        = "#b8bb26",
      blue         = "#83a598",
      yellow       = "#fe8019",
      gray         = "#a89984",
      darkgray     = "#3c3836",
      lightgray    = "#504945",
      inactivegray = "#7c6f64",
    }

    auto_theme_custom.command.a.bg = "None"
    auto_theme_custom.command.b.bg = "None"

    auto_theme_custom.inactive.a.bg = "None"
    auto_theme_custom.inactive.b.bg = "None"
    auto_theme_custom.inactive.c.bg = "None"

    auto_theme_custom.insert.a.bg = "None"
    auto_theme_custom.insert.b.bg = "None"

    auto_theme_custom.normal.a.bg = "None"
    auto_theme_custom.normal.b.bg = "None"
    auto_theme_custom.normal.c.bg = "None"

    auto_theme_custom.replace.a.bg = "None"
    auto_theme_custom.replace.b.bg = "None"

    auto_theme_custom.terminal.a.bg = "None"
    auto_theme_custom.terminal.b.bg = "None"

    auto_theme_custom.visual.a.fg = colors.blue
    auto_theme_custom.command.a.fg = colors.blue
    auto_theme_custom.inactive.a.fg = colors.blue
    auto_theme_custom.insert.a.fg = colors.blue
    auto_theme_custom.normal.a.fg = colors.blue
    auto_theme_custom.replace.a.fg = colors.blue
    auto_theme_custom.terminal.a.fg = colors.blue
    auto_theme_custom.visual.a.fg = colors.blue

    local function session_name()
      -- return require("possession.session").get_session_name() or ""
    end
    lualine.setup({
      options = {
        theme = auto_theme_custom
      },
      sections = {
        lualine_a = { "filename" },
        lualine_c = {},
        lualine_x = { "lsp_status", "filetype" },
        lualine_y = { session_name }
      },
    })
  end
}
