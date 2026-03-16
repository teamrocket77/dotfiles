-- fmt
-- https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- https://github.com/michaelbrusegard/awesome-wezterm?tab=readme-ov-file#neovim
-- https://github.com/sei40kr/wez-logging
local wezterm = require("wezterm") --[[@as Wezterm]]
local io = require("io")
local act = wezterm.action
local maps = require("maps")

local home = os.getenv("HOME")
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
-- local logging = wezterm.plugin.require("https://github.com/sei40kr/wez-logging")

-- This will hold the default configuration
local config = wezterm.config_builder()
require("custom-events")

local color_schemes = {
  "Apple Classic",
  "AlienBlood"
}

for k, v in pairs({
  -- default_prog = { "/opt/homebrew/bin/nu" },
  default_workspace = "init",
  ssh_domains = {
    {
      name = "drif",
      remote_address = "192.168.0.194",
      username = "drif",
      -- multiplexing = "Ssh",
    }
  },
  audible_bell = "Disabled",
  -- font = wezterm.font("JetBrains Mono"),
  font_size = 16,
  scrollback_lines = 20000,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
  keys = maps.keys,
  window_padding = {
    left = 3,
    right = 3,
    top = 20,
    bottom = 0,
  },
  window_decorations = "RESIZE",
  automatically_reload_config = true,
  window_background_opacity = .7,
  macos_window_background_blur = 40,
  notification_handling = "AlwaysShow",
  color_scheme = "Grey-green",
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

maps.apply(config)
wezterm.plugin.list()

return config
