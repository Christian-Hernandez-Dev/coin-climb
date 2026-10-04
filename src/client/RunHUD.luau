-- On-screen run info: a timer at the top of the screen (with your best time under it)
-- and a Restart button below the General Store button.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local formatTime = require(ReplicatedStorage.Shared.TimeFormat)

local WOOD = Color3.fromRGB(95, 55, 30)
local CREAM = Color3.fromRGB(250, 235, 200)
local GOLD = Color3.fromRGB(255, 200, 40)
local FONT = Enum.Font.FredokaOne

local RunHUD = {}

local player = Players.LocalPlayer

local function makeTimer(gui)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 12)
	frame.Size = UDim2.new(0, 220, 0, 64)
	frame.BackgroundColor3 = WOOD
	frame.BackgroundTransparency = 0.15
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	frame.Parent = gui

	local function label(y, height, color)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.new(0, 0, 0, y)
		l.Size = UDim2.new(1, 0, 0, height)
		l.Font = FONT
		l.TextScaled = true
		l.TextColor3 = color
		l.Parent = frame
		return l
	end
	local timeLabel = label(4, 34, CREAM)
	local bestLabel = label(40, 20, GOLD)

	-- Every frame: show the live clock while running, otherwise the last result or a hint
	RunService.RenderStepped:Connect(function()
		local runStart = player:GetAttribute("RunStart")
		local lastTime = player:GetAttribute("LastTime")
		if runStart then
			-- Server time on both sides, so this matches what the server will record
			timeLabel.Text = "⏱ " .. formatTime(workspace:GetServerTimeNow() - runStart)
		elseif lastTime then
			timeLabel.Text = "⏱ " .. formatTime(lastTime)
		else
			timeLabel.Text = "Hop on the blue pad!"
		end

		local best = player:GetAttribute("BestTime")
		bestLabel.Text = if best then "Best: " .. formatTime(best) else "Best: --"
	end)
end

local function makeRestartButton(gui)
	local restartRun = ReplicatedStorage:WaitForChild("RestartRun")

	local button = Instance.new("TextButton")
	button.Text = "↺ Restart"
	button.Position = UDim2.new(0, 16, 0, 74) -- just below the General Store button (top-left, clear of the phone thumbstick)
	button.Size = UDim2.new(0, 200, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(191, 10, 48) -- Texas red
	button.TextColor3 = CREAM
	button.Font = FONT
	button.TextScaled = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	button.Parent = gui

	button.Activated:Connect(function()
		restartRun:FireServer() -- the server does the actual reset
	end)
end

function RunHUD.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "RunHUD"
	gui.ResetOnSpawn = false
	makeTimer(gui)
	makeRestartButton(gui)
	gui.Parent = player:WaitForChild("PlayerGui")
end

return RunHUD
