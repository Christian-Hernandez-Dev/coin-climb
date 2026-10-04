-- Upgrade definitions, shared so the shop UI (client) shows exactly the prices the server charges.

local Upgrades = {}

-- Display order in the shop
Upgrades.order = { "Speed", "Jump" }

Upgrades.list = {
	Speed = {
		displayName = "Roadrunner Boots",
		description = "Run faster",
		maxLevel = 5,
		baseCost = 10,
		-- Character WalkSpeed at a given level (Roblox default is 16)
		value = function(level)
			return 16 + level * 3
		end,
	},
	Jump = {
		displayName = "Jackrabbit Legs",
		description = "Jump higher",
		maxLevel = 5,
		baseCost = 15,
		-- Character JumpHeight in studs at a given level (Roblox default is 7.2)
		value = function(level)
			return 7.2 + level * 1.5
		end,
	},
}

-- Price of buying `level` (each level costs more than the last)
function Upgrades.cost(upgrade, level)
	return upgrade.baseCost * level
end

-- The player attribute that stores their level, e.g. "SpeedLevel"
function Upgrades.attribute(id)
	return id .. "Level"
end

return Upgrades
