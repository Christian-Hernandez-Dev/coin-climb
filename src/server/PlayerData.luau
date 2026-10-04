-- Saves each player's coins, upgrade levels, and best time to a DataStore (Roblox's cloud storage)
-- and loads them when they join.
--
-- In Studio this only works once the place is saved to Roblox and
-- Game Settings → Security → "Enable Studio Access to API Services" is on.
-- Without that, the game still runs; it just starts fresh each time.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local AUTOSAVE_SECONDS = 60
local SAVED_ATTRIBUTES = { "SpeedLevel", "JumpLevel", "BestTime" }

local PlayerData = {}

-- Bump the version if the saved format ever changes in an incompatible way
local store = DataStoreService:GetDataStore("PlayerData_v1")

local function keyFor(player)
	return "Player_" .. player.UserId
end

local function load(player)
	-- DataStore calls go over the network and can fail, so pcall catches errors instead of crashing the script
	local ok, data = pcall(function()
		return store:GetAsync(keyFor(player))
	end)
	if not ok then
		-- Leave DataLoaded unset: saving is then skipped, so a failed load can't overwrite real saved data with zeros
		warn("Couldn't load data for " .. player.Name .. " (progress won't be saved this session): " .. tostring(data))
		return
	end

	data = data or {} -- nil means a brand-new player
	local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
	coins.Value += data.Coins or 0 -- add, so coins grabbed while loading aren't lost
	for _, name in SAVED_ATTRIBUTES do
		if data[name] ~= nil then
			player:SetAttribute(name, data[name])
		end
	end
	player:SetAttribute("DataLoaded", true)
end

local function save(player)
	if not player:GetAttribute("DataLoaded") then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local data = { Coins = leaderstats.Coins.Value }
	for _, name in SAVED_ATTRIBUTES do
		data[name] = player:GetAttribute(name)
	end

	local ok, err = pcall(function()
		store:SetAsync(keyFor(player), data)
	end)
	if not ok then
		warn("Couldn't save data for " .. player.Name .. ": " .. tostring(err))
	end
end

function PlayerData.start()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do -- players who joined before this ran
		task.spawn(load, player)
	end

	Players.PlayerRemoving:Connect(save)

	-- When the server shuts down (or you press Stop in Studio), save everyone before it closes
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			save(player)
		end
	end)

	-- Autosave regularly, so a crash loses at most a minute of progress
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for _, player in Players:GetPlayers() do
				task.spawn(save, player)
			end
		end
	end)
end

return PlayerData
