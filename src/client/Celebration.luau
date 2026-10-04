-- Finish-line celebration: a "YEEHAW!" banner and fireworks in Texas red, white, blue, and gold.
-- The server decides when you've finished and sends the "Celebrate" RemoteEvent; this just puts on the show.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Audio = require(script.Parent.Audio)
local formatTime = require(ReplicatedStorage.Shared.TimeFormat)

local FIREWORK_COLORS = {
	Color3.fromRGB(191, 10, 48), -- Texas red
	Color3.fromRGB(255, 255, 255), -- white
	Color3.fromRGB(40, 90, 255), -- blue (brighter than the flag so it glows at night)
	Color3.fromRGB(255, 200, 40), -- Lone Star gold
}
local ROCKET_COUNT = 14
local SHOW_SECONDS = 4 -- rockets are launched spread across this long

local Celebration = {}

local random = Random.new()

-- A small anchored part that players can't touch or bump into, used to hold effects
local function effectPart(position)
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.4, 1, 0.4)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = workspace
	return part
end

-- The explosion: a burst of glowing sparks flying out in every direction, then falling, plus a flash of light
local function burst(position, color)
	local holder = effectPart(position)
	holder.Transparency = 1

	local sparks = Instance.new("ParticleEmitter")
	sparks.Color = ColorSequence.new(color, Color3.new(1, 1, 1)) -- fades toward white as they burn out
	sparks.LightEmission = 1 -- glow
	sparks.Size = NumberSequence.new(0.8, 0)
	sparks.Lifetime = NumberRange.new(1.2, 1.8)
	sparks.Speed = NumberRange.new(18, 26)
	sparks.SpreadAngle = Vector2.new(180, 180) -- all directions
	sparks.Drag = 2.5 -- slow down after the pop
	sparks.Acceleration = Vector3.new(0, -12, 0) -- then droop under gravity
	sparks.Rate = 0 -- don't emit on its own; we emit once below
	sparks.Parent = holder
	sparks:Emit(120)

	local flash = Instance.new("PointLight")
	flash.Color = color
	flash.Range = 40
	flash.Brightness = 6
	flash.Parent = holder
	TweenService:Create(flash, TweenInfo.new(1), { Brightness = 0 }):Play()

	Debris:AddItem(holder, 3) -- clean up once the sparks are gone
end

-- A rocket shoots up with a sparkly trail, then bursts at the top
local function launchRocket(from)
	local color = FIREWORK_COLORS[random:NextInteger(1, #FIREWORK_COLORS)]

	local rocket = effectPart(from)
	rocket.Color = color
	rocket.Material = Enum.Material.Neon

	local trail = Instance.new("ParticleEmitter")
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 180, 80))
	trail.LightEmission = 1
	trail.Size = NumberSequence.new(0.4, 0)
	trail.Lifetime = NumberRange.new(0.3, 0.5)
	trail.Speed = NumberRange.new(1, 2)
	trail.Rate = 60
	trail.Parent = rocket

	local top = from + Vector3.new(random:NextNumber(-5, 5), random:NextNumber(22, 35), random:NextNumber(-5, 5))
	local rise = TweenService:Create(rocket, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = top })
	rise:Play()
	rise.Completed:Wait()

	rocket:Destroy()
	burst(top, color)
	Audio.play("firework")
end

local function showBanner(duration, time, newBest)
	local gui = Instance.new("ScreenGui")
	gui.Name = "CelebrationBanner"
	gui.ResetOnSpawn = false -- we remove it ourselves

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.3)
	title.Size = UDim2.fromScale(0.7, 0.15)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.Text = "YEEHAW! You made it! 🤠"
	title.TextColor3 = Color3.fromRGB(255, 200, 40)
	title.TextScaled = true
	title.Parent = gui

	local outline = Instance.new("UIStroke")
	outline.Thickness = 3
	outline.Color = Color3.fromRGB(120, 40, 10)
	outline.Parent = title

	local subtitle = title:Clone()
	subtitle.Position = UDim2.fromScale(0.5, 0.42)
	subtitle.Size = UDim2.fromScale(0.5, 0.06)
	if time then
		subtitle.Text = "Time: " .. formatTime(time) .. (if newBest then "   ⭐ NEW BEST! ⭐" else "")
	else
		subtitle.Text = "Heading back to the start for another run..."
	end
	subtitle.TextColor3 = Color3.new(1, 1, 1)
	subtitle.Parent = gui

	-- Pop in: start tiny and spring up to full size
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = title
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	TweenService:Create(scale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	Debris:AddItem(gui, duration)
end

local function onCelebrate(finishPosition, duration, time, newBest)
	showBanner(duration, time, newBest)
	Audio.play("finish")
	for _ = 1, ROCKET_COUNT do
		-- launch from random spots around the finish pad, a little apart in time
		local from = finishPosition + Vector3.new(random:NextNumber(-10, 10), 1, random:NextNumber(-10, 10))
		task.spawn(launchRocket, from)
		task.wait(SHOW_SECONDS / ROCKET_COUNT)
	end
end

function Celebration.start()
	local celebrate = ReplicatedStorage:WaitForChild("Celebrate")
	celebrate.OnClientEvent:Connect(onCelebrate)
end

return Celebration
