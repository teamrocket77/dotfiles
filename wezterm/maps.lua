-- fmt
local wezterm = require("wezterm") --[[@as Wezterm]]
local resurrect = require("resurrect")

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
  { key = "l", mods = "LEADER|CTRL", action = wezterm.action.ShowLauncher },
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
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      workspace_switcher.switch_workspace()
    end),
  },
  {
    key = "s",
    mods = "LEADER|CTRL",
    action = wezterm.action.EmitEvent("trigger-vim-with-scrollback"),
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
      resurrect.resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
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
}
return keys
