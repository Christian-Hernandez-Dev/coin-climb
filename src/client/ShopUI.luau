-- The General Store window: a button in the top-left opens a panel listing each upgrade
-- with its level, price, and a Buy button. Purchases go through the server's "BuyUpgrade" RemoteFunction.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Audio = require(script.Parent.Audio)
local Upgrades = require(ReplicatedStorage.Shared.Upgrades)

-- Saloon look: dark wood, cream text, gold buttons
local WOOD = Color3.fromRGB(95, 55, 30)
local WOOD_DARK = Color3.fromRGB(60, 35, 20)
local CREAM = Color3.fromRGB(250, 235, 200)
local GOLD = Color3.fromRGB(255, 200, 40)
local DISABLED = Color3.fromRGB(120, 110, 100)
local FONT = Enum.Font.FredokaOne

local ShopUI = {}

local player = Players.LocalPlayer

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = FONT
	l.TextColor3 = CREAM
	l.TextScaled = true
	for key, value in props do
		l[key] = value
	end
	l.Parent = parent
	return l
end

local function button(parent, props)
	local b = Instance.new("TextButton")
	b.Font = FONT
	b.TextScaled = true
	b.AutoButtonColor = true
	for key, value in props do
		b[key] = value
	end
	corner(b, 8)
	b.Parent = parent
	return b
end

-- One row in the panel: name and description on the left, level in the middle, Buy button on the right.
-- Returns a function that redraws the row from the player's current level and coins.
local function makeRow(parent, id, order, showMessage, buyUpgrade)
	local upgrade = Upgrades.list[id]

	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 64)
	row.BackgroundColor3 = WOOD_DARK
	corner(row, 10)
	row.Parent = parent

	label(row, { Text = upgrade.displayName, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(0.45, 0, 0, 28), TextXAlignment = Enum.TextXAlignment.Left })
	label(row, {
		Text = upgrade.description,
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(0.45, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(210, 190, 160),
	})
	local levelLabel = label(row, { Position = UDim2.new(0.47, 0, 0, 18), Size = UDim2.new(0.18, 0, 0, 28) })
	local buy = button(row, { Position = UDim2.new(0.67, 0, 0, 12), Size = UDim2.new(0.31, 0, 0, 40), TextColor3 = WOOD_DARK })

	local function refresh()
		local level = player:GetAttribute(Upgrades.attribute(id)) or 0
		levelLabel.Text = "Lv " .. level .. "/" .. upgrade.maxLevel
		if level >= upgrade.maxLevel then
			buy.Text = "MAXED"
			buy.BackgroundColor3 = DISABLED
			return
		end
		local cost = Upgrades.cost(upgrade, level + 1)
		local coins = player.leaderstats.Coins.Value
		buy.Text = "Buy: " .. cost .. " coins"
		buy.BackgroundColor3 = if coins >= cost then GOLD else DISABLED -- gray when you can't afford it
	end

	buy.Activated:Connect(function()
		local success, message = buyUpgrade:InvokeServer(id) -- waits for the server's answer
		showMessage(message, success)
		if success then
			Audio.play("purchase")
		end
	end)

	return refresh
end

function ShopUI.build()
	local buyUpgrade = ReplicatedStorage:WaitForChild("BuyUpgrade")
	local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")

	local gui = Instance.new("ScreenGui")
	gui.Name = "ShopUI"
	gui.ResetOnSpawn = false -- keep the window as-is when respawning

	local openButton = button(gui, {
		Text = "🤠 General Store",
		-- Top-left: on phones the bottom-left is the movement thumbstick.
		-- ScreenGuis keep clear of Roblox's top bar and phone notches by default (ScreenInsets).
		Position = UDim2.new(0, 16, 0, 16),
		Size = UDim2.new(0, 200, 0, 50),
		BackgroundColor3 = WOOD,
		TextColor3 = GOLD,
	})

	local panel = Instance.new("Frame")
	panel.Visible = false
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(0, 460, 0, 260)
	panel.BackgroundColor3 = WOOD
	corner(panel, 14)
	local border = Instance.new("UIStroke")
	border.Thickness = 3
	border.Color = GOLD
	border.Parent = panel
	panel.Parent = gui

	label(panel, { Text = "General Store", Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 0, 36), TextColor3 = GOLD })
	local close = button(panel, {
		Text = "X",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundColor3 = Color3.fromRGB(191, 10, 48),
		TextColor3 = CREAM,
	})

	local list = Instance.new("Frame")
	list.BackgroundTransparency = 1
	list.Position = UDim2.new(0, 16, 0, 56)
	list.Size = UDim2.new(1, -32, 0, 140)
	list.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local message = label(panel, { Text = "", Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 30) })
	local messageId = 0
	local function showMessage(text, success)
		message.Text = text
		message.TextColor3 = if success then Color3.fromRGB(120, 230, 120) else Color3.fromRGB(255, 120, 100)
		messageId += 1
		local mine = messageId
		task.delay(2.5, function()
			if messageId == mine then -- don't clear a newer message
				message.Text = ""
			end
		end)
	end

	local refreshers = {}
	for i, id in Upgrades.order do
		table.insert(refreshers, makeRow(list, id, i, showMessage, buyUpgrade))
	end
	local function refreshAll()
		for _, refresh in refreshers do
			refresh()
		end
	end

	-- Redraw whenever coins or upgrade levels change
	coins.Changed:Connect(refreshAll)
	for _, id in Upgrades.order do
		player:GetAttributeChangedSignal(Upgrades.attribute(id)):Connect(refreshAll)
	end
	refreshAll()

	openButton.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)
	close.Activated:Connect(function()
		panel.Visible = false
	end)

	gui.Parent = player:WaitForChild("PlayerGui")
end

return ShopUI
