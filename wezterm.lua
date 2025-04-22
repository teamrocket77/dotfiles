-- fmt
-- https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- https://github.com/michaelbrusegard/awesome-wezterm?tab=readme-ov-file#neovim
-- https://github.com/sei40kr/wez-logging
local wezterm = require("wezterm") --[[@as Wezterm]]
local config = wezterm.config_builder()
local home = os.getenv("HOME")
local image_location = home .. "/.config/nvim/background.jpeg"

config = {
	-- window_background_image = image_location,
	-- color_scheme = "AdventureTime",
	scrollback_lines = 20000,
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
	keys = {
		{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
		{ key = "|", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
		-- Make Option-Right equivalent to Alt-f; forward-word
		{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
		{ key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
		{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
		{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
		{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	},
}
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
