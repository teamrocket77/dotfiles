local wezterm = require("wezterm") --[[@as Wezterm]]
local io = require("io")
local act = wezterm.action
local maps = require("maps")

local home = os.getenv("HOME")
-- NOTE: bar.wezterm intentionally not required — we use our own status line
-- (update-status / update-right-status) and tab bar (colors.tab_bar,
-- format-tab-title). Requiring it without bar.apply_to_config(config) floods
-- the logs with nil 'separator'/'padding' errors on every render.
-- local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
-- local logging = wezterm.plugin.require("https://github.com/sei40kr/wez-logging")

-- This will hold the default configuration
local config = wezterm.config_builder() ---@type Config


require("custom-events")
local font_size = 14
local current_theme = "Grey-green"
local scheme = wezterm.color.get_builtin_schemes()[current_theme]
local color_schemes = {
  "Apple Classic",
  "AlienBlood",
  "Grey-green"
}
local bg = scheme and scheme.background or "#1c1c1c"
local fg = scheme and scheme.foreground or "#d0d0d0"


config.default_workspace = "init"
config.audible_bell = "Disabled"
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = font_size
config.scrollback_lines = 20000
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = maps.keys
config.window_padding = {
  left = 3,
  right = 3,
  top = 20,
  bottom = 0,
}

config.default_workspace = "init"
config.audible_bell = "Disabled"
config.font_size = font_size
config.window_decorations = "RESIZE"
config.automatically_reload_config = true
config.window_background_opacity = 1
config.macos_window_background_blur = 40
config.notification_handling = "AlwaysShow"
config.color_scheme = current_theme
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- dim inactive splits (background + text), like a stronger version of
-- kitty's inactive_text_alpha. 1.0 = no change.
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}
config.window_frame = {
  font_size = 10
}

local status_cache = { cpu = "NA", mem = "NA", rendered = "" }

wezterm.on("update-status", function(window, pane)
  window:set_left_status("")
end)

wezterm.on("update-right-status", function(window, pane)
  local workspace = window:active_workspace()
  local ok_cpu, out_cpu = wezterm.run_child_process({ "sh", "-c", "sysctl -n vm.loadavg | awk '{print $2}'" })
  status_cache.cpu = ok_cpu and out_cpu:gsub("\n", "") or "NA"
  status_cache.cpu = out_cpu:gsub("^%s*(.-)%s*$", "%1")
  local ok_mem, out_mem = wezterm.run_child_process({ "sh", "-c",
    "memory_pressure | grep 'System-wide memory free percentage' | awk '{print 100-$5\"%\"}'" })
  status_cache.mem = ok_mem and out_mem:gsub("\n", "") or "NA"
  local text = "C: " .. status_cache.cpu .. " R: " .. status_cache.mem .. " "
  window:set_right_status(wezterm.format({
    "ResetAttributes",
    { Foreground = { Color = fg } },
    { Text = "^: " .. workspace .. " | " },
    "ResetAttributes",
    { Foreground = { Color = fg } },
    { Text = text },
  }))
end)

config.colors = {
  tab_bar = {
    background = bg,
    active_tab = {
      bg_color = bg,
      fg_color = fg,
      intensity = "Bold"
    },
    inactive_tab = {
      bg_color = bg,
      fg_color = "#666666"
    },
    inactive_tab_hover = {
      bg_color = bg,
      fg_color = fg,
    },
    new_tab = {
      bg_color = bg,
      fg_color = "#666666"
    },
    new_tab_hover = {
      bg_color = bg,
      fg_color = fg,
    },
  }
}

maps.apply(config)
wezterm.plugin.list()

return config
