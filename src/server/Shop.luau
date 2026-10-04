-- The General Store: handles upgrade purchases and applies upgrade levels to the character.
-- Clients ask to buy through the "BuyUpgrade" RemoteFunction; the server checks everything,
-- because anything coming from a client could be faked.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Upgrades = require(ReplicatedStorage.Shared.Upgrades)

local Shop = {}

-- A RemoteFunction is like a RemoteEvent, but the caller waits for an answer (did the purchase work?)
local buyUpgrade = Instance.new("RemoteFunction")
buyUpgrade.Name = "BuyUpgrade"
buyUpgrade.Parent = ReplicatedStorage

local function applyUpgrades(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = Upgrades.list.Speed.value(player:GetAttribute(Upgrades.attribute("Speed")) or 0)
	humanoid.UseJumpPower = false -- use JumpHeight (studs) rather than the older JumpPower
	humanoid.JumpHeight = Upgrades.list.Jump.value(player:GetAttribute(Upgrades.attribute("Jump")) or 0)
end

-- Returns: success (boolean), message to show the player
local function onBuyRequest(player, id)
	local upgrade = typeof(id) == "string" and Upgrades.list[id]
	if not upgrade then
		return false, "That's not for sale"
	end

	local attribute = Upgrades.attribute(id)
	local level = player:GetAttribute(attribute)
	if level >= upgrade.maxLevel then
		return false, "Already maxed out!"
	end

	local cost = Upgrades.cost(upgrade, level + 1)
	local coins = player.leaderstats.Coins
	if coins.Value < cost then
		return false, "Not enough coins, partner"
	end

	coins.Value -= cost
	player:SetAttribute(attribute, level + 1) -- the attribute-changed listener applies it to the character
	return true, upgrade.displayName .. " upgraded!"
end

local function onPlayerAdded(player)
	for _, id in Upgrades.order do
		local attribute = Upgrades.attribute(id)
		if player:GetAttribute(attribute) == nil then -- PlayerData may have already loaded a saved level
			player:SetAttribute(attribute, 0)
		end
		-- Re-apply whenever a level changes, whether from buying or from loading saved data
		player:GetAttributeChangedSignal(attribute):Connect(function()
			if player.Character then
				applyUpgrades(player, player.Character)
			end
		end)
	end
	player.CharacterAdded:Connect(function(character)
		applyUpgrades(player, character)
	end)
	if player.Character then
		applyUpgrades(player, player.Character)
	end
end

function Shop.start()
	buyUpgrade.OnServerInvoke = onBuyRequest
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do -- players who joined before this ran
		onPlayerAdded(player)
	end
end

return Shop
