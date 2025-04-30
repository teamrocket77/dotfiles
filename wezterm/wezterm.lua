-- fmt
-- https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- https://github.com/michaelbrusegard/awesome-wezterm?tab=readme-ov-file#neovim
-- https://github.com/sei40kr/wez-logging
local wezterm = require("wezterm") --[[@as Wezterm]]
local config = wezterm.config_builder()
local home = os.getenv("HOME")
local image_location = home .. "/.config/nvim/background.jpeg"
local plugin_home = home .. "/.config/wezterm"
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local logging = wezterm.plugin.require("https://github.com/sei40kr/wez-logging")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local colors = require("colors")
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")

resurrect.state_manager.periodic_save({
  interval_seconds = 15 * 60,
  save_workspaces = true,
  save_windows = true,
  save_tabs = true,
})

wezterm.on("resurrect.error", function(err)
  wezterm.log_error("ERROR!")
  wezterm.gui.gui_windows()[1]:toast_notification("resurrect", err, nil, 3000)
end)

workspace_switcher.workspace_formatter = function(label)
  return wezterm.format({
    { Attribute = { Italic = true } },
    { Foreground = { Color = colors.colors.ansi[3] } },
    { Background = { Color = colors.colors.background } },
    { Text = "󱂬 : " .. label },
  })
end

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
  window:gui_window():set_right_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = colors.colors.ansi[5] } },
    { Text = basename(path) .. "  " },
  }))
  local workspace_state = resurrect.workspace_state

  workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
    window = window,
    relative = true,
    restore_text = true,

    resize_window = false,
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
  })
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
  wezterm.log_info(window)
  window:gui_window():set_right_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = colors.colors.ansi[5] } },
    { Text = basename(path) .. "  " },
  }))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
  wezterm.log_info(window)
  local workspace_state = resurrect.workspace_state
  resurrect.state_manager.save_state(workspace_state.get_workspace_state())
  resurrect.state_manager.write_current_state(label, "workspace")
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.start", function(window, _)
  wezterm.log_info(window)
end)
wezterm.on("smart_workspace_switcher.workspace_switcher.canceled", function(window, _)
  wezterm.log_info(window)
end)

config = {
  default_workspace = "~",
  audible_bell = "Disabled",
  -- window_background_image = image_location,
  color_scheme = "AdventureTime",
  font_size = 16,
  scrollback_lines = 20000,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
  keys = {
    {
      key = "!",
      mods = "LEADER|SHIFT",
      action = wezterm.action_callback(function(win, pane)
        pane:move_to_new_tab()
      end),
    },
    { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "|", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
    { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "l", mods = "CTRL", action = wezterm.action.ShowLauncher },
    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    {
      key = ",",
      mods = "LEADER",
      action = wezterm.action.PromptInputLine({
        description = "Enter new name for tab",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },
    -- { key = "x", mods = "LEADER", action = logging.action.CaptureViewPort }, -- not working like it should
    -- { key = "x", mods = "LEADER|SHIFT", action = logging.action.CaptureScrollback }, -- not sure about this
    {
      key = "s",
      mods = "LEADER",
      action = wezterm.action_callback(function(win, pane)
        workspace_switcher.switch_workspace()
      end),
    },
    {
      key = "r",
      mods = "LEADER",
      action = wezterm.action.PromptInputLine({
        description = "Enter new name for workspace",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      }),
    },
    {
      key = "r",
      mods = "LEADER|CTRL",
      action = wezterm.action_callback(function(win, pane)
        local win_id = win:window_id()
        resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
          local type = string.match(id, "^([^/]+)") -- match before '/'
          id = string.match(id, "([^/]+)$") -- match after '/'
          id = string.match(id, "(.+)%..+$") -- remove file extention
          local opts = {
            relative = true,
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          }
          if type == "workspace" then
            local state = resurrect.state_manager.load_state(id, "workspace")
            resurrect.workspace_state.restore_workspace(state, opts)
          elseif type == "window" then
            local state = resurrect.state_manager.load_state(id, "window")
            resurrect.window_state.restore_window(pane:window(), state, opts)
          elseif type == "tab" then
            local state = resurrect.state_manager.load_state(id, "tab")
            resurrect.tab_state.restore_tab(pane:tab(), state, opts)
          end
        end)
      end),
    },
  },
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
workspace_switcher.apply_to_config(config)

return config
