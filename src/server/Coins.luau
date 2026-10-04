-- Coin collecting: every player gets a "Coins" counter, and touching a part tagged "Coin"
-- adds its "Value" attribute to it. Collected coins hide, then come back so they can be farmed for upgrades.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local RESPAWN_SECONDS = 20

local Coins = {}

local function onPlayerAdded(player)
	-- A folder named exactly "leaderstats" makes Roblox show its values in the player list (top-right)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats

	leaderstats.Parent = player
end

local function collect(coin, player)
	coin:SetAttribute("Collected", true) -- stops a second touch from counting before it hides
	coin.Transparency = 1
	player.leaderstats.Coins.Value += coin:GetAttribute("Value")

	task.delay(RESPAWN_SECONDS, function()
		coin:SetAttribute("Collected", false)
		coin.Transparency = 0
	end)
end

local function setUpCoin(coin)
	coin.Touched:Connect(function(hit)
		if coin:GetAttribute("Collected") then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			collect(coin, player)
		end
	end)
end

function Coins.start()
	for _, coin in CollectionService:GetTagged("Coin") do
		setUpCoin(coin)
	end
	CollectionService:GetInstanceAddedSignal("Coin"):Connect(setUpCoin)

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do -- players who joined before this ran
		onPlayerAdded(player)
	end
end

return Coins
