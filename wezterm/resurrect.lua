-- fmt
local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local colors = require("colors")
local os = require("os")
local io = require("io")

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

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
  local name = os.tmpname()
  local f = io.open(name, "w+")
  f:write(text)
  f:flush()
  f:close()
  window:perform_action(
    wezterm.action.SpawnCommandInNewWindow({
      args = { "vim", name },
    }),
    pane
  )
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

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

return {
  resurrect = resurrect,
  workspace_switcher = workspace_switcher,
}
