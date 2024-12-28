-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This table will hold the configuration.
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local act = wezterm.action

-- general configurations
config = {
	automatically_reload_config = true,
	default_prog = { "bash.exe" },
	enable_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resizable border
	color_scheme = "rose-pine-moon",
	font = wezterm.font("JetBrainsMono Nerd Font Mono"),
	font_size = 12,
	detect_password_input = true,
	tab_bar_at_bottom = true,
	tab_and_split_indices_are_zero_based = true,
	use_fancy_tab_bar = false,
	window_padding = { left = 5, right = 3, top = 3, bottom = 0 },
	-- default_domain = "WSL:Ubuntu",
  -- set_environment_variables = {
  --   PATH = "/c/Users/Acer/wezterm_config;"..os.getenv("PATH"),
  -- },
}

-- text on right-most side of tab line (status)
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

-- mapping custom keybindings for window pane navigation
config.keys = {
	------------------------------------------------ PANE SPLITING ------------------------------------------------
	-- This will create a new split and run your default program inside it
	{ key = '"', mods = "CTRL|SHIFT|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = ":", mods = "CTRL|SHIFT|ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	------------------------------------------------ PANE NAVIGATION ------------------------------------------------
	-- adjust pane size
	{ key = "h", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "j", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "h", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "l", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 1 }) },

	-- select active pane
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

	------------------------------------------------ WORKSPACE CONFIGURATION ------------------------------------------------
	-- Prompt for a name to use for a new workspace and switch to it.
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},

	-- switch to default workspace
	{ key = "d", mods = "CTRL|SHIFT", action = act.SwitchToWorkspace({ name = "default" }) },

	-- switch relative tab
	{ key = "n", mods = "CTRL|ALT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "p", mods = "CTRL|ALT", action = act.SwitchWorkspaceRelative(-1) },

	-- list all workspaces
	{ key = "9", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	------------------------------------------------ WORKSPACE CONFIGURATION ------------------------------------------------
	{ key = "UpArrow", mods = "SHIFT", action = act.ScrollByPage(1) },
	{ key = "DownArrow", mods = "SHIFT", action = act.ScrollByPage(-1) },

	------------------------------------------------ TOGGLE BACKGROUND OPACITY ------------------------------------------------
	-- { key = "b", mods = "CTRL", action = act.EmitEvent 'toggle-opacity' },
}

-- and finally, return the configuration to wezterm
return config
