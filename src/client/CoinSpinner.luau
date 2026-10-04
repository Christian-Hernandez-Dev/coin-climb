-- Spins and bobs every coin. Done on the client because it's purely visual;
-- the server still decides when a coin is collected.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local SPIN_SPEED = math.rad(120) -- degrees per second
local BOB_HEIGHT = 0.3

local CoinSpinner = {}

local coins = {} -- [coin part] = its original CFrame

local function add(coin)
	coins[coin] = coin.CFrame
end

local function remove(coin)
	coins[coin] = nil
end

function CoinSpinner.start()
	for _, coin in CollectionService:GetTagged("Coin") do
		add(coin)
	end
	-- Coins can load in and out as the player moves around, so track them as they come and go
	CollectionService:GetInstanceAddedSignal("Coin"):Connect(add)
	CollectionService:GetInstanceRemovedSignal("Coin"):Connect(remove)

	RunService.RenderStepped:Connect(function()
		local t = os.clock()
		local offset = CFrame.new(0, math.sin(t * 2) * BOB_HEIGHT, 0) * CFrame.Angles(0, t * SPIN_SPEED, 0)
		for coin, original in coins do
			coin.CFrame = original * offset
		end
	end)
end

return CoinSpinner
