-- For LUA to actually find the module, it has to reside in a path included in the lua cpath
-- See: https://github.com/FelixKratz/SbarLua
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

local sbar = require("sketchybar")

-- Allow `require` to resolve modules relative to this file (constants.lua,
-- colors.lua, icons.lua, and the items/ package) regardless of sketchybar's cwd.
local config_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path

-- Bundle the entire config into a single message to sketchybar for fast startup
sbar.begin_config()

--- Bar Appearance ---
-- https://felixkratz.github.io/SketchyBar/config/bar

sbar.bar({
	position = "top",
	height = 30,
	display = "main",
	color = 0x00000000,
	border_width = 0,
	shadow = false,
	-- Required by sketchybar-toggle (https://github.com/malpern/sketchybar-toggle)
	-- so it can slide the bar via y_offset instead of the window sitting
	-- under the native menu bar when it un-hides.
	topmost = "window",
})

--- Changing Defaults ---
-- These are applied to all further items.
-- https://felixkratz.github.io/SketchyBar/config/items

sbar.default({
	padding_left = 0,
	padding_right = 5,
	icon = {
		font = { family = "CommitMono Nerd Font", style = "Bold", size = 17.0 },
		color = 0xffffffff,
		padding_left = 0,
		padding_right = 4,
	},
	label = {
		font = { family = "CommitMono", style = "Regular", size = 14.0 },
		color = 0xffffffff,
		padding_left = 0,
		padding_right = 4,
	},
})

--- Adding Left Items ---
-- Left-side items live in items/ (see items/spaces.lua for the AeroSpace
-- workspace indicators). Requiring this module mounts its items as a
-- side effect, same as every other item below.

require("items")

--- Adding Right Items ---
-- Some items refresh on a fixed cycle via update_freq (delivered as a
-- "routine" event), others respond to events they subscribe to.
-- https://felixkratz.github.io/SketchyBar/config/events

local clock = sbar.add("item", "clock", {
	position = "right",
	update_freq = 10,
	icon = { string = "" },
})

local function clock_update()
	sbar.exec("date '+%m/%d %H:%M'", function(result)
		clock:set({ label = result })
	end)
end

clock:subscribe("routine", clock_update)
clock_update()

local volume = sbar.add("item", "volume", {
	position = "right",
})

volume:subscribe("volume_change", function(env)
	local pct = tonumber(env.INFO)
	local icon

	if pct == nil or pct == 0 then
		icon = "󰖁"
	elseif pct < 30 then
		icon = "󰕿"
	elseif pct < 60 then
		icon = "󰖀"
	else
		icon = "󰕾"
	end

	volume:set({ icon = icon, label = pct .. "%" })
end)

-- Memory *pressure* (kern.memorystatus_vm_pressure_level), not raw %-used --
-- this is the same normal/warning/critical signal Activity Monitor's memory
-- gauge shows, and stats_provider's RAM_USAGE doesn't capture it.
local ram = sbar.add("item", "ram", {
	position = "right",
	update_freq = 5,
})

local function ram_update()
	sbar.exec("sysctl -n kern.memorystatus_vm_pressure_level", function(result)
		local level = tonumber(result)
		local label, color

		if level == 4 then
			label, color = "􀫦􀃮", 0xffff3b30
		elseif level == 2 then
			label, color = "􀫦", 0xffff9500
		end

		ram:set({
			drawing = level == 2 or level == 4,
			label = { string = label, color = color },
		})
	end)
end

ram:subscribe("routine", ram_update)
ram_update()

local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(result)
		local pct = tonumber(result:match("(%d+)%%"))
		if pct == nil then
			return
		end

		local icon
		if pct >= 90 then
			icon = ""
		elseif pct >= 60 then
			icon = ""
		elseif pct >= 30 then
			icon = ""
		elseif pct >= 10 then
			icon = ""
		else
			icon = ""
		end

		if result:find("AC Power") then
			icon = ""
		end

		battery:set({ icon = icon, label = pct .. "%" })
	end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change" }, battery_update)
battery_update()

sbar.end_config()

-- Auto-hide the bar near the screen top so it doesn't fight the native
-- auto-hiding menu bar: https://github.com/malpern/sketchybar-toggle
sbar.exec("pkill -x sketchybar-toggle; sketchybar-toggle &")

-- Run the event loop, so subscribed callback functions actually get executed
sbar.event_loop()
