-- fmt
local wezterm = require("wezterm") --[[@as Wezterm]]
local action = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
require("resurrect-events")

local keys = {
  {
    key = "!",
    mods = "LEADER|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = "-",          mods = "LEADER",      action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "DownArrow",  mods = "LEADER",      action = action.ActivatePaneDirection("Down") },
  { key = "LeftArrow",  mods = "CMD|SHIFT",   action = action.ActivateTabRelative(-1) },
  { key = "LeftArrow",  mods = "LEADER",      action = action.ActivatePaneDirection("Left") },
  { key = "LeftArrow",  mods = "OPT",         action = action({ SendString = "\x1bb" }) },
  { key = "RightArrow", mods = "CMD|SHIFT",   action = action.ActivateTabRelative(1) },
  { key = "RightArrow", mods = "LEADER",      action = action.ActivatePaneDirection("Right") },
  { key = "RightArrow", mods = "OPT",         action = action({ SendString = "\x1bf" }) },
  { key = "UpArrow",    mods = "LEADER",      action = action.ActivatePaneDirection("Up") },
  { key = "[",          mods = "LEADER",      action = action.ActivateCopyMode },
  { key = "[",          mods = "LEADER|CTRL", action = action.SwitchWorkspaceRelative(-1) },
  { key = "]",          mods = "LEADER|CTRL", action = action.SwitchWorkspaceRelative(1) },
  { key = "c",          mods = "LEADER",      action = action.SpawnTab("CurrentPaneDomain") },
  { key = "e",          mods = "LEADER",      action = action.EmitEvent("trigger-vim-with-scrollback") },
  { key = "h",          mods = "LEADER",      action = action.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",      action = action.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",      action = action.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",      action = action.ActivatePaneDirection("Right") },
  { key = "l",          mods = "LEADER|CTRL", action = action.ShowLauncher },
  { key = "n",          mods = "LEADER",      action = action.ActivateTabRelative(1) },
  { key = "p",          mods = "CMD",         action = action.CloseCurrentPane({ confirm = true }) },
  { key = "p",          mods = "LEADER",      action = action.ActivateTabRelative(-1) },
  { key = "t",          mods = "LEADER",      action = action.CloseCurrentTab({ confirm = true }) },
  { key = "z",          mods = "LEADER",      action = action.TogglePaneZoomState },
  { key = "|",          mods = "LEADER",      action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
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

        local opts = {
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          spawn_in_workspace = true,
          relative = true,
          restore_text = true,
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
  {
    key = "$",
    mods = "LEADER|SHIFT",
    action = action.PromptInputLine({
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
return keys
