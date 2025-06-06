-- fmt
local wezterm = require("wezterm") --[[@as Wezterm]]
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
require("resurrect-events")

keys = {
  {
    key = "!",
    mods = "LEADER|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  },
  { key = "c",          mods = "LEADER",      action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "|",          mods = "LEADER",      action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-",          mods = "LEADER",      action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "LeftArrow",  mods = "OPT",         action = wezterm.action({ SendString = "\x1bb" }) },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = "RightArrow", mods = "OPT",         action = wezterm.action({ SendString = "\x1bf" }) },
  { key = "LeftArrow",  mods = "CMD|SHIFT",   action = wezterm.action.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CMD|SHIFT",   action = wezterm.action.ActivateTabRelative(1) },
  { key = "n",          mods = "LEADER",      action = wezterm.action.ActivateTabRelative(1) },
  { key = "p",          mods = "LEADER",      action = wezterm.action.ActivateTabRelative(-1) },
  { key = "z",          mods = "LEADER",      action = wezterm.action.TogglePaneZoomState },
  { key = "[",          mods = "LEADER",      action = wezterm.action.ActivateCopyMode },
  { key = "h",          mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "LeftArrow",  mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "DownArrow",  mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "UpArrow",    mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "LEADER",      action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "l",          mods = "LEADER|CTRL", action = wezterm.action.ShowLauncher },
  { key = "e",          mods = "LEADER",      action = wezterm.action.EmitEvent("trigger-vim-with-scrollback") },
  { key = "]",          mods = "LEADER|CTRL", action = wezterm.action.SwitchWorkspaceRelative(1) },
  { key = "[",          mods = "LEADER|CTRL", action = wezterm.action.SwitchWorkspaceRelative(-1) },
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
  {
    key = "s",
    mods = "LEADER|CTRL",
    action = workspace_switcher.switch_workspace(),
  },
  {
    key = "w",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    end),
  },
  {
    key = "r",
    mods = "LEADER|CTRL",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$")         -- match after '/'
        id = string.match(id, "(.+)%..+$")        -- remove file extention

        win:perform_action(
          wezterm.action.SwitchToWorkspace({ name = id }), pane
        )
        win:perform_action({
          EmitEvent = {
            event = 'restore-workspace',
            id = id,
            type = type
          }
        })
      end)
    end)
  },
  {
    key = "$",
    mods = "LEADER|SHIFT",
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
    key = "d",
    mods = "LEADER|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        resurrect.state_manager.delete_state(id)
      end, {
        title = "Delete State",
        description = "Select session to delete and press enter",
        fuzzy_description = "Search session to delete: ",
        is_fuzzy = true,
      })
    end),
  },
}
wezterm.on("restore-workspace", function(window, pane, event)
  window:toast_notification("wezterm", "Workspace restored", nil, 4000)
  local opts = {
    close_open_tabs = true,
    window = pane:window(),
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    spawn_in_workspace = true,
    restore_text = true,
    relative = true,
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

return keys
