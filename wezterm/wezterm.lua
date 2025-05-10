-- fmt
-- https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- https://github.com/michaelbrusegard/awesome-wezterm?tab=readme-ov-file#neovim
-- https://github.com/sei40kr/wez-logging
local wezterm = require("wezterm") --[[@as Wezterm]]
local resurrect = require("resurrect")
local keys = require("maps")

local config = wezterm.config_builder()
local home = os.getenv("HOME")
local image_location = home .. "/.config/nvim/background.jpeg"
local plugin_home = home .. "/.config/wezterm"
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local logging = wezterm.plugin.require("https://github.com/sei40kr/wez-logging")
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")

config = {
  default_workspace = "~",
  audible_bell = "Disabled",
  -- color_scheme = "AdventureTime",
  font_size = 16,
  scrollback_lines = 20000,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
  keys = keys,
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i - 1),
  })
end

bar.apply_to_config(config, {
  modules = {
    tabs = {
      active_tab_fg = 2,
      inactive_tab_fg = 4,
    },
    pane = { enabled = false },
    cwd = { enabled = false },
    username = { enabled = false },
  },
})
resurrect.workspace_switcher.apply_to_config(config)

return config
