-- Inspiration from:
-- https://github.com/Kainoa-h/aerospace-sketchybar/blob/main/sketchybar/sketchybarrc
-- https://github.com/haxybaxy/dotfiles/tree/master/sketchybar/.config/sketchybar

local sbar = require("sketchybar")
local constants = require("constants")
local colors = require("colors")
local icon_map = require("icon_map")

-- Only render workspaces marked as persistent unless a non-persistent one is active
local PERSISTENT = constants.aerospace.PERSISTENT_WORKSPACES
local PERSISTENT_SET = {}
for _, id in ipairs(PERSISTENT) do
	PERSISTENT_SET[id] = true
end

local items = {} -- workspace id -> sbar item
local focused = nil
local currentMode = "main"

local function getWorkspaceColor(id)
	local isActive = id == focused
	if isActive then
		return currentMode == "main" and colors.orange or colors.green
	else
		return currentMode == "main" and colors.white or colors.orange
	end
end

-- Persistent workspaces are always visible; non-persistent (letter) ones
-- are only shown while they're the focused workspace.
local function isVisible(id)
	return PERSISTENT_SET[id] == true or id == focused
end

local function restyle(id)
	local item = items[id]
	if item then
		item:set({
			drawing = isVisible(id),
			icon = { color = getWorkspaceColor(id) },
		})
	end
end

local function restyleAll()
	for id in pairs(items) do
		restyle(id)
	end
end

local function ensureItem(id)
	if items[id] then
		return items[id]
	end

	local item = sbar.add("item", constants.items.SPACES .. "." .. id, {
		drawing = isVisible(id),
		icon = {
			font = { family = "CommitMono", style = "Regular", size = 15.0 },
			string = id,
			color = getWorkspaceColor(id),
			padding_left = 0,
			padding_right = 4,
		},
		label = {
			font = { family = constants.APP_ICON_FONT, style = "Regular", size = 14.0 },
			string = "",
			padding_left = 2,
			padding_right = 12,
		},
		click_script = "aerospace workspace " .. id,
	})
	items[id] = item
	return item
end

local function removeItem(id)
	if items[id] then
		sbar.remove(items[id])
		items[id] = nil
	end
end

-- Updates one workspace's app-icon strip (its label) from its current windows.
local function refreshIcons(id)
	sbar.exec("aerospace list-windows --workspace " .. id .. " --format '%{app-name}'", function(output)
		local icons = {}
		local seen = {}
		for name in output:gmatch("[^\r\n]+") do
			if name ~= "" and not seen[name] then
				seen[name] = true
				icons[#icons + 1] = icon_map[name] or constants.DEFAULT_APP_ICON
			end
		end

		local item = items[id]
		if item then
			item:set({ label = { string = table.concat(icons, " ") } })
		end
	end)
end

-- Persistent workspaces always exist; non-persistent ones are shown to their
-- right only while they have windows, in the order they're first seen.
local function reconcile()
	for _, id in ipairs(PERSISTENT) do
		ensureItem(id)
		refreshIcons(id)
		restyle(id)
	end

	sbar.exec(constants.aerospace.LIST_NONEMPTY_WORKSPACES, function(output)
		local wanted = {}
		for _, id in ipairs(PERSISTENT) do
			wanted[id] = true
		end

		for id in output:gmatch("[^\r\n]+") do
			if id ~= "" and not PERSISTENT_SET[id] then
				wanted[id] = true
				ensureItem(id)
				refreshIcons(id)
				restyle(id)
			end
		end

		for id in pairs(items) do
			if not wanted[id] then
				removeItem(id)
			end
		end
	end)
end

local function onWorkspaceChanged(newWorkspace)
	focused = newWorkspace
	restyleAll()
	-- Also reconcile immediately: the newly-focused workspace may be a
	-- non-persistent one we haven't created an item for yet.
	reconcile()
end

local function onModeChanged(newMode)
	currentMode = newMode
	restyleAll()
end

-- AeroSpace triggers these via `exec-on-workspace-change` and `on-mode-changed`
-- in aerospace.toml; they must be registered before anything can subscribe.
sbar.add("event", constants.events.AEROSPACE_WORKSPACE_CHANGED)
sbar.add("event", constants.events.AEROSPACE_MODE_CHANGED)

-- update_freq polls as a fallback since AeroSpace has no on-window-closed
-- callback; on-window-detected in aerospace.toml also triggers a reconcile
-- on window open for a faster response.
local watcher = sbar.add("item", { drawing = false, updates = true, update_freq = 5 })

watcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	onWorkspaceChanged(env.FOCUSED_WORKSPACE)
end)

watcher:subscribe(constants.events.AEROSPACE_MODE_CHANGED, function(_)
	sbar.exec(constants.aerospace.GET_CURRENT_MODE, function(output)
		onModeChanged(output:match("[^\r\n]+") or "main")
	end)
end)

watcher:subscribe("routine", reconcile)

sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(output)
	focused = output:match("[^\r\n]+") or "1"
	restyleAll()
end)

sbar.exec(constants.aerospace.GET_CURRENT_MODE, function(output)
	currentMode = output:match("[^\r\n]+") or "main"
	restyleAll()
end)

reconcile()
