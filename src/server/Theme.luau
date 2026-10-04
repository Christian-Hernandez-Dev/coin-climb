-- Texas desert look: sand ground and sunset lighting.
-- Changes are made when the game starts, so the place file in Studio stays untouched.
-- Decorations (cacti, animals, clouds...) live in the client's Scenery module.

local Lighting = game:GetService("Lighting")

local SAND = Color3.fromRGB(215, 170, 110)

local Theme = {}

local function setUpGround()
	local baseplate = workspace:FindFirstChild("Baseplate")
	if not baseplate then
		return
	end
	baseplate.Color = SAND
	baseplate.Material = Enum.Material.Sand
	local grid = baseplate:FindFirstChildOfClass("Texture") -- the template's checker grid
	if grid then
		grid:Destroy()
	end
end

local function setUpLighting()
	Lighting.ClockTime = 17.8 -- just before sunset
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 110, 80)

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.35
	atmosphere.Haze = 1.5
	atmosphere.Color = Color3.fromRGB(240, 190, 140) -- dusty orange air
	atmosphere.Decay = Color3.fromRGB(200, 120, 80)
	atmosphere.Parent = Lighting
end

function Theme.apply()
	setUpGround()
	setUpLighting()
end

return Theme
