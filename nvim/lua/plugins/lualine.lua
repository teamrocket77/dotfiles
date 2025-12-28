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

    -- this is continuously called
    -- TODO: fix me
    local function session_name()
      local cwd = vim.fn.getcwd()
      local handler = io.popen("ls -a " .. cwd)
      local result = handler:read("*a")
      if result == nil then
        return [[Error]]
      end
      local result_table = {}
      for line in result:gmatch("([^\n]*)") do
        table.insert(result_table, line)
      end
      local filename_to_match = "Session.vim"
      local found_session = false
      vim.print(result)
      vim.print(result_table)
      for _, file in ipairs(result_table) do
        if file == filename_to_match then
          found_session = true
          break
        end
      end
      vim.print(found_session)
      if found_session then
        return [[Session Valid]]
      end
      return [[Session invalid]]
    end
    vim.api.nvim_create_user_command("CheckForSession", session_name, {})
    lualine.setup({
      options = {
        theme = auto_theme_custom
      },
      sections = {
        lualine_a = {
          { "filename",  path = 1 },
          { "fileformat" },
        },
        lualine_c = {},
        lualine_x = { "lsp_status", "filetype" },
        lualine_z = {
        }
      },
    })
  end
}
