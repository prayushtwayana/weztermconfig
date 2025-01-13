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
  -- default_prog = { "tmux" },
  -- hide_tab_bar_if_only_one_tab = true,
	enable_tab_bar = true,
	tab_bar_at_bottom = true,
	show_new_tab_button_in_tab_bar = false,
	window_close_confirmation = "AlwaysPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resizable border
	color_scheme = "rose-pine-moon",
	font = wezterm.font("JetBrainsMono Nerd Font Mono"),
	font_size = 15,
	detect_password_input = true,
	tab_and_split_indices_are_zero_based = true,
	use_fancy_tab_bar = false,
  tab_max_width = 20,
	window_padding = { left = 5, right = 3, top = 3, bottom = 0 },
}

-- text on right-most side of tab line (status)
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

config.unix_domains = {
  {
    name = 'unix',
  },
}

-- map the leader key
config.leader = {
  key = "a",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

-- mapping custom keybindings for window pane navigation
config.keys = {
	------------------------------------------------ PANE SPLITING ------------------------------------------------
	-- This will create a new split and run your default program inside it
	{ key = "'", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = ";", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	------------------------------------------------ PANE NAVIGATION ------------------------------------------------
	-- adjust pane size
	{ key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },

	-- select active pane
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- pane zoom
	{ key = "0", mods = "ALT", action = act.TogglePaneZoomState },

	------------------------------------------------ TAB CONFIGURATION ------------------------------------------------
	-- Rename the current tab
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia"} },
          { Text = "Enter new name for tab: " },
        }),
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },

  -- show tab navigator
	{ key = "/", mods = "CTRL", action = act.ShowTabNavigator },

  -- new tab
	{ key = "t", mods = "CTRL", action = act.SpawnTab 'CurrentPaneDomain' },

	------------------------------------------------ WORKSPACE / SESSION CONFIGURATION ------------------------------------------------
 -- Attach to muxer
  { key = 'a', mods = 'LEADER', action = act.AttachDomain 'unix' },

  -- Detach from muxer
  { key = 'd', mods = 'LEADER', action = act.DetachDomain { DomainName = 'unix' } },

  -- Rename current session
  {
      key = 'r',
      mods = 'LEADER',
      action = act.PromptInputLine {
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter new name for workspace: " },
        }),
        action = wezterm.action_callback(
          function(window, pane, line)
            if line then
              wezterm.mux.rename_workspace(
                window:mux_window():get_workspace(),
                line
              )
            end
          end
        ),
      },
    },

	-- switch to default workspace
	{ key = "d", mods = "LEADER", action = act.SwitchToWorkspace({ name = "default" }) },

	-- switch relative workspace 
	{ key = "p", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	{ key = "n", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },

	-- list all workspaces
	{ key = "9", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	------------------------------------------------ (GLOBAL) COPY MODE ------------------------------------------------
	{ key = "[", mods = "CTRL", action = act.ActivateCopyMode },

	------------------------------------------------ TOGGLE BACKGROUND OPACITY ------------------------------------------------
	-- { key = "b", mods = "CTRL", action = act.EmitEvent 'toggle-opacity' },
}

-- and finally, return the configuration to wezterm
return config
