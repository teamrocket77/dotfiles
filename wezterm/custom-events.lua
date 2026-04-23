local wezterm = require("wezterm") --[[@as Wezterm]]
local io = require("io")
local os = require("os")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local home = os.getenv("HOME")
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


local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
  local args = cmd and cmd.args or {}

  -- Set a workspace for coding
  local personal_vault = home .. "/Documents/vaults/personal"
  local config_dir = home .. "/dotfiles"


  mux.spawn_window {
    workspace = "obsidian vault",
    cwd = personal_vault,
    args = args,
  }

  -- A workspace for automation
  mux.spawn_window {
    workspace = "config-main",
    cwd = config_dir,
    args = args,
  }

  mux.spawn_window {
    workspace = "config-nested",
    cwd = config_dir .. "/.config",
    args = args,
  }
  mux.spawn_window {
    workspace = "init",
    cwd = home,
    args = args,
  }
end)

function get_folder_basename(path)
  -- Get the platform-specific directory separator (e.g., "/" or "\\")
  local separator = package.config:sub(1, 1)

  -- Normalize the path: replace all alternative separators with the standard one
  if separator == "\\" then
    path = path:gsub("/", "\\")
  else
    path = path:gsub("\\", "/")
  end

  -- Remove a trailing separator if it exists
  path = path:gsub(separator .. "$", "")

  -- Extract the basename using pattern matching
  -- The pattern matches everything after the last separator
  local basename = path:match(".*" .. separator .. "([^" .. separator .. "]*)$")

  -- If no separator was found, the whole path is the basename
  if not basename then
    basename = path:match("([^" .. separator .. "]*)$")
  end

  return basename
end

resurrect.state_manager.periodic_save({
  save_workspaces = true,
  save_windows = true,
  save_tabs = true,
})

wezterm.on("resurrect.workspace_state.restore_workspace.finished", function(...)
  local msg = "Resurrected"
  wezterm.gui.gui_windows()[1]:toast_notification("Wezterm - resurrect", msg, nil, 4000)
end)

wezterm.on("resurrect.state_manager.save_state.finished", function(window, pane)
  local msg = "Saved"
  window:toast_notification("Wezterm - save", msg, nil, 4000)
end)

wezterm.on("window-config-reloaded", function(window, pane)
  window:toast_notification("wezterm", "Reloaded config", nil, 4000)
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
    { Text = get_folder_basename(path) .. "  " },
  }))
  local workspace_state = resurrect.workspace_state

  workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
    close_open_tabs = true,
    window = window:window(),
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    relative = true,
    restore_text = true,
  })
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
  wezterm.log_info(window)
  window:gui_window():set_right_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = colors.colors.ansi[5] } },
    { Text = get_folder_basename(path) .. "  " },
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

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on(
  "format-tab-title",
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab)
    if tab.is_active then
      return {
        { Background = { Color = "blue" } },
        { Text = " " .. title .. " " },
      }
    end
    if tab.is_last_active then
      -- Green color and append '*' to previously active tab.
      return {
        { Background = { Color = "green" } },
        { Text = " " .. title .. "*" },
      }
    end
    return title
  end
)
