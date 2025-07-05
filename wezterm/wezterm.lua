-- fmt
-- https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- https://github.com/michaelbrusegard/awesome-wezterm?tab=readme-ov-file#neovim
-- https://github.com/sei40kr/wez-logging
local wezterm = require("wezterm") --[[@as Wezterm]]
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local keys = require("maps")

local home = os.getenv("HOME")
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local logging = wezterm.plugin.require("https://github.com/sei40kr/wez-logging")
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")

-- This will hold the default configuration
local config = wezterm.config_builder()

for k, v in pairs({
  default_workspace = "init",
  audible_bell = "Disabled",
  color_scheme = "AdventureTime",
  font = wezterm.font("JetBrains Mono"),
  font_size = 16,
  scrollback_lines = 20000,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
  keys = keys,
  default_cursor_style = "BlinkingBar",
  color_scheme = "Nord (Gogh)",
  window_padding = {
    left = 3,
    right = 3,
    top = 0,
    bottom = 0,
  },
  window_decorations = "RESIZE",
  automatically_reload_config = true,
  window_background_opacity = 0.6,
  macos_window_background_blur = 20,
  notification_handling = "AlwaysShow",
}) do
  config[k] = v
end

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
return config
