return {
	items = {
		SPACES = "space",
	},

	events = {
		AEROSPACE_WORKSPACE_CHANGED = "aerospace_workspace_change",
		AEROSPACE_MODE_CHANGED = "aerospace_mode_changed",
	},

	aerospace = {
		GET_CURRENT_WORKSPACE = "aerospace list-workspaces --focused",
		GET_CURRENT_MODE = "aerospace list-modes --current",
		LIST_NONEMPTY_WORKSPACES = "aerospace list-workspaces --monitor all --empty no",

		-- Must match `persistent-workspaces` in aerospace.toml: these are
		-- always shown, in this order, regardless of whether they have windows.
		PERSISTENT_WORKSPACES = { "1", "2", "3" },
	},

	-- https://github.com/kvndrsslr/sketchybar-app-font
	APP_ICON_FONT = "sketchybar-app-font",
	DEFAULT_APP_ICON = ":default:",
}
