-- The Coin Climb course, as data. Edit these lists to change the course;
-- CourseBuilder turns them into parts.
--
-- size:       width (X), height (Y), depth (Z) in studs
-- position:   center of the part. The course runs toward -Z, away from spawn.
-- style:      look of the platform (see STYLES)
-- checkpoint: optional; reaching this platform makes it your respawn point.
--             Numbers must go up along the course.
-- runStart:   optional; stepping here starts the run timer.
-- finish:     optional; landing here stops the timer, triggers the celebration, and restarts the run.
-- Default character jumps ~7 studs up and ~10-12 studs forward.

-- Texas desert theme
local STYLES = {
	start = { color = Color3.fromRGB(0, 40, 104), material = Enum.Material.SmoothPlastic }, -- Texas flag blue
	wood = { color = Color3.fromRGB(160, 110, 60), material = Enum.Material.WoodPlanks },
	hay = { color = Color3.fromRGB(225, 190, 100), material = Enum.Material.Fabric },
	metal = { color = Color3.fromRGB(150, 85, 55), material = Enum.Material.CorrodedMetal }, -- harder jumps
	finish = { color = Color3.fromRGB(191, 10, 48), material = Enum.Material.SmoothPlastic }, -- Texas flag red
}

return {
	platforms = {
		{ name = "Start", size = Vector3.new(10, 1, 10), position = Vector3.new(0, 2, -18), style = STYLES.start, runStart = true },
		{ name = "Platform1", size = Vector3.new(8, 1, 8), position = Vector3.new(0, 3, -31), style = STYLES.wood },
		{ name = "Platform2", size = Vector3.new(6, 1, 6), position = Vector3.new(6, 5, -42), style = STYLES.hay },
		{ name = "Platform3", size = Vector3.new(6, 1, 6), position = Vector3.new(0, 7, -52), style = STYLES.wood, checkpoint = 1 },
		{ name = "Platform4", size = Vector3.new(4, 1, 4), position = Vector3.new(0, 7, -62), style = STYLES.metal },
		{ name = "Platform5", size = Vector3.new(4, 1, 4), position = Vector3.new(-6, 9, -71), style = STYLES.metal },
		{ name = "Platform6", size = Vector3.new(6, 1, 6), position = Vector3.new(0, 11, -81), style = STYLES.hay, checkpoint = 2 },
		{ name = "Finish", size = Vector3.new(12, 1, 12), position = Vector3.new(0, 12, -94), style = STYLES.finish, finish = true },
	},

	-- Gold coins. Each is worth `value` (default 1) and comes back a while after being collected.
	-- Some float over gaps, so grabbing them means jumping through them.
	coins = {
		{ position = Vector3.new(0, 6, -31) }, -- Platform1
		{ position = Vector3.new(3, 9, -37) }, -- over the gap to Platform2
		{ position = Vector3.new(6, 8, -42) }, -- Platform2
		{ position = Vector3.new(0, 10, -52) }, -- Platform3
		{ position = Vector3.new(0, 10, -62) }, -- Platform4
		{ position = Vector3.new(-6, 12, -71) }, -- Platform5
		{ position = Vector3.new(0, 16, -87) }, -- over the gap to the Finish
		{ position = Vector3.new(-3, 15, -94) }, -- Finish
		{ position = Vector3.new(0, 15, -94) },
		{ position = Vector3.new(3, 15, -94) },

		-- Bonus coins, worth 5: too high to reach without Jackrabbit Legs upgrades
		{ position = Vector3.new(0, 26, -52), value = 5 }, -- above Platform3 (needs about Jump Lv 3)
		{ position = Vector3.new(0, 28, -81), value = 5 }, -- above Platform6 (needs about Jump Lv 2)
	},

	-- Touching any of these defeats the player. Themed as a pit of red-hot chili.
	lava = {
		-- Floor under the course, from just past the Start pad to beyond the Finish.
		-- Sits on top of the baseplate, so the area around spawn stays safe.
		{ name = "ChiliPit", size = Vector3.new(60, 1, 84), position = Vector3.new(0, 0.5, -66) },
	},
}
