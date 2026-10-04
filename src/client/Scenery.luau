-- Texas desert scenery: cacti, mesas, longhorns, a windmill, a Texas flag,
-- drifting clouds, circling vultures, and rolling tumbleweeds.
--
-- Built on the client because it's purely visual: each player's device makes its own copy,
-- so moving things animate smoothly without the server sending updates every frame.

local RunService = game:GetService("RunService")

local Scenery = {}

local random = Random.new(1836) -- fixed seed: same layout every play (1836 = Texas independence)
local updaters = {} -- functions called every frame with (t, dt) to animate things

-- Cylinders lie along X; this stands one upright
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local CACTUS = Color3.fromRGB(75, 130, 60)

local function part(parent, props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		p[key] = value
	end
	p.Parent = parent
	return p
end

-- A saguaro: a trunk with one arm on each side at different heights
local function makeCactus(parent, position, height)
	local model = Instance.new("Model")
	model.Name = "Cactus"
	local look = { Shape = Enum.PartType.Cylinder, Color = CACTUS, Material = Enum.Material.Grass, CanCollide = true }

	local function cylinder(size, cframe)
		local p = part(model, look)
		p.Size = size
		p.CFrame = cframe
	end

	cylinder(Vector3.new(height, 2, 2), CFrame.new(position + Vector3.new(0, height / 2, 0)) * UPRIGHT)
	for _, arm in { { side = 1, at = 0.45 }, { side = -1, at = 0.6 } } do
		local y = height * arm.at
		-- horizontal stub out from the trunk, then a vertical piece pointing up
		cylinder(Vector3.new(2, 1.2, 1.2), CFrame.new(position + Vector3.new(arm.side * 1.6, y, 0)))
		cylinder(Vector3.new(3, 1.2, 1.2), CFrame.new(position + Vector3.new(arm.side * 2.4, y + 1.4, 0)) * UPRIGHT)
	end

	model.Parent = parent
end

-- Flat-topped rock formation: stacked layers that shrink toward the top, in alternating red bands
local function makeMesa(parent, position, width, height)
	local model = Instance.new("Model")
	model.Name = "Mesa"
	local layers = 3
	local layerHeight = height / layers
	for i = 0, layers - 1 do
		local w = width * (1 - i * 0.18)
		part(model, {
			Size = Vector3.new(w, layerHeight, w * 0.6),
			Position = position + Vector3.new(0, layerHeight * i + layerHeight / 2, 0),
			Color = if i % 2 == 0 then Color3.fromRGB(185, 95, 55) else Color3.fromRGB(165, 80, 45),
			Material = Enum.Material.Sandstone,
		})
	end
	model.Parent = parent
end

-- Blocky longhorn steer facing along its CFrame's look direction
local function makeLonghorn(parent, cframe, coat)
	local model = Instance.new("Model")
	model.Name = "Longhorn"
	local horn = Color3.fromRGB(240, 230, 200)
	local dark = Color3.fromRGB(60, 40, 25)

	local function piece(size, offset, color)
		part(model, { Size = size, CFrame = cframe * CFrame.new(offset), Color = color, CanCollide = true })
	end

	piece(Vector3.new(2.4, 2.4, 5), Vector3.new(0, 3.4, 0), coat) -- body
	piece(Vector3.new(1.6, 1.6, 1.8), Vector3.new(0, 4.2, -3.2), coat) -- head
	piece(Vector3.new(1.2, 1, 0.6), Vector3.new(0, 3.8, -4.3), Color3.fromRGB(200, 150, 120)) -- snout
	piece(Vector3.new(6, 0.35, 0.35), Vector3.new(0, 5.1, -3), horn) -- the famous wide horns
	piece(Vector3.new(0.35, 1, 0.35), Vector3.new(3, 5.5, -3), horn) -- horn tips curving up
	piece(Vector3.new(0.35, 1, 0.35), Vector3.new(-3, 5.5, -3), horn)
	piece(Vector3.new(0.25, 2, 0.25), Vector3.new(0, 3, 2.6), dark) -- tail
	for _, leg in { Vector3.new(0.8, 1.1, 1.8), Vector3.new(-0.8, 1.1, 1.8), Vector3.new(0.8, 1.1, -1.8), Vector3.new(-0.8, 1.1, -1.8) } do
		piece(Vector3.new(0.6, 2.2, 0.6), leg, dark)
	end

	model.Parent = parent
end

-- Classic Texas water-pumping windmill with spinning blades
local function makeWindmill(parent, position)
	local model = Instance.new("Model")
	model.Name = "Windmill"
	local metal = { Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Metal }

	local height = 24
	local tower = part(model, metal)
	tower.Size = Vector3.new(1, height, 1)
	tower.Position = position + Vector3.new(0, height / 2, 0)
	tower.CanCollide = true

	local hubPosition = position + Vector3.new(0, height, -0.8)
	local tail = part(model, metal)
	tail.Size = Vector3.new(0.2, 2.5, 4)
	tail.Position = position + Vector3.new(0, height, 2.5)

	local blades = {}
	local bladeCount = 12
	for i = 1, bladeCount do
		local blade = part(model, { Size = Vector3.new(0.8, 4, 0.1), Color = Color3.fromRGB(200, 200, 200), Material = Enum.Material.Metal })
		blades[i] = blade
	end
	model.Parent = parent

	-- Blades face the course (along Z) and spin around the hub
	table.insert(updaters, function(t)
		for i, blade in blades do
			local angle = t * 1.5 + (i / bladeCount) * math.pi * 2
			blade.CFrame = CFrame.new(hubPosition) * CFrame.Angles(0, 0, angle) * CFrame.new(0, 2.5, 0)
		end
	end)
end

-- Texas flag on a tall pole: blue band with a white star, white over red stripes
local function makeTexasFlag(parent, position)
	local model = Instance.new("Model")
	model.Name = "TexasFlag"
	local poleHeight = 24
	part(model, {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(poleHeight, 0.5, 0.5),
		CFrame = CFrame.new(position + Vector3.new(0, poleHeight / 2, 0)) * UPRIGHT,
		Color = Color3.fromRGB(200, 200, 200),
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	local top = position.Y + poleHeight - 0.5
	local left = position.X + 0.3
	local function panel(size, x, y, color)
		return part(model, { Size = size, Position = Vector3.new(x, y, position.Z), Color = color, Material = Enum.Material.Fabric })
	end
	panel(Vector3.new(3, 6, 0.2), left + 1.5, top - 3, Color3.fromRGB(0, 40, 104)) -- blue band
	panel(Vector3.new(6, 3, 0.2), left + 6, top - 1.5, Color3.fromRGB(255, 255, 255)) -- white stripe
	panel(Vector3.new(6, 3, 0.2), left + 6, top - 4.5, Color3.fromRGB(191, 10, 48)) -- red stripe
	-- The lone star, approximated by two overlapping rotated squares
	for _, turn in { 0, 45 } do
		local star = panel(Vector3.new(1.3, 1.3, 0.3), left + 1.5, top - 3, Color3.fromRGB(255, 255, 255))
		star.CFrame = star.CFrame * CFrame.Angles(0, 0, math.rad(turn))
	end
	model.Parent = parent
end

-- A puffy cloud that drifts slowly across the sky and wraps around
local function makeCloud(parent, center)
	local model = Instance.new("Model")
	model.Name = "Cloud"
	local puffs = {}
	for _ = 1, random:NextInteger(4, 6) do
		local size = random:NextNumber(12, 24)
		local puff = part(model, {
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size, size),
			Color = Color3.fromRGB(255, 250, 245),
			Material = Enum.Material.SmoothPlastic,
			Transparency = 0.1,
			CastShadow = false,
		})
		table.insert(puffs, { part = puff, offset = Vector3.new(random:NextNumber(-18, 18), random:NextNumber(-3, 4), random:NextNumber(-8, 8)) })
	end
	model.Parent = parent

	local speed = random:NextNumber(2, 5)
	table.insert(updaters, function(_, dt)
		center += Vector3.new(speed * dt, 0, 0)
		if center.X > 400 then
			center -= Vector3.new(800, 0, 0)
		end
		for _, puff in puffs do
			puff.part.Position = center + puff.offset
		end
	end)
end

-- A turkey vulture (dark body, red head) gliding in a circle above the course
local function makeVulture(parent, center, radius, phase)
	local model = Instance.new("Model")
	model.Name = "Vulture"
	local black = Color3.fromRGB(30, 25, 25)
	local pieces = {
		{ part = part(model, { Size = Vector3.new(0.8, 0.6, 2), Color = black }), offset = CFrame.new() }, -- body
		{ part = part(model, { Size = Vector3.new(0.4, 0.4, 0.5), Color = Color3.fromRGB(170, 40, 40) }), offset = CFrame.new(0, 0.1, -1.2) }, -- head
		-- wings angled slightly upward, the way vultures soar
		{ part = part(model, { Size = Vector3.new(3, 0.15, 1.2), Color = black }), offset = CFrame.new(1.8, 0.25, 0) * CFrame.Angles(0, 0, math.rad(12)) },
		{ part = part(model, { Size = Vector3.new(3, 0.15, 1.2), Color = black }), offset = CFrame.new(-1.8, 0.25, 0) * CFrame.Angles(0, 0, math.rad(-12)) },
	}
	model.Parent = parent

	table.insert(updaters, function(t)
		local angle = t * 0.3 + phase
		local position = center + Vector3.new(math.cos(angle) * radius, math.sin(t * 0.5 + phase) * 2, math.sin(angle) * radius)
		local heading = Vector3.new(-math.sin(angle), 0, math.cos(angle)) -- direction of travel around the circle
		local base = CFrame.lookAt(position, position + heading) * CFrame.Angles(0, 0, math.rad(-20)) -- bank into the turn
		for _, piece in pieces do
			piece.part.CFrame = base * piece.offset
		end
	end)
end

-- A tumbleweed that bounces and rolls across the desert, then starts over on the far side
local function makeTumbleweed(parent)
	local size = random:NextNumber(2.5, 4)
	local weed = part(parent, {
		Name = "Tumbleweed",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(size, size, size),
		Color = Color3.fromRGB(165, 125, 80),
		Material = Enum.Material.Grass,
		Transparency = 0.25,
	})

	local x = random:NextNumber(-150, 150)
	local z = random:NextNumber(-120, 20)
	local speed = random:NextNumber(8, 14)
	local spin = 0
	table.insert(updaters, function(t, dt)
		x += speed * dt
		if x > 150 then
			x = -150
			z = random:NextNumber(-120, 20)
		end
		spin -= speed / (size / 2) * dt -- roll at the speed it travels
		local bounce = math.abs(math.sin(t * 3 + z)) * 1.5
		weed.CFrame = CFrame.new(x, size / 2 + bounce, z) * CFrame.Angles(0, 0, spin)
	end)
end

-- Where the landmarks stand: { position, facing in degrees }
local HERD = {
	{ Vector3.new(-48, 0, -30), 30 },
	{ Vector3.new(-55, 0, -38), 200 },
	{ Vector3.new(-44, 0, -45), 110 },
	{ Vector3.new(52, 0, -70), -60 },
	{ Vector3.new(60, 0, -78), 150 },
}
local WINDMILL_POSITION = Vector3.new(-40, 0, -8)
local FLAG_POSITION = Vector3.new(-14, 0, -8)

-- Spots cacti must stay away from, so they don't grow through cows or landmarks
local function buildClearSpots()
	local spots = {
		{ position = WINDMILL_POSITION, radius = 7 },
		{ position = FLAG_POSITION, radius = 5 },
	}
	for _, cow in HERD do
		table.insert(spots, { position = cow[1], radius = 10 }) -- covers the horns plus a cactus's arms
	end
	return spots
end

local function isClear(position, spots)
	for _, spot in spots do
		if (position - spot.position).Magnitude < spot.radius then
			return false
		end
	end
	return true
end

function Scenery.build()
	local folder = Instance.new("Folder")
	folder.Name = "Scenery"

	-- Cacti on either side of the chili pit (which spans X -30..30), along the length of the course
	local clearSpots = buildClearSpots()
	for _ = 1, 30 do
		local position
		repeat -- keep picking until the spot isn't on top of a cow or landmark
			local side = if random:NextNumber() < 0.5 then -1 else 1
			position = Vector3.new(side * random:NextNumber(36, 90), 0, random:NextNumber(-130, 10))
		until isClear(position, clearSpots)
		makeCactus(folder, position, random:NextNumber(7, 12))
	end

	-- Mesas far away on the horizon
	for _, mesa in {
		{ Vector3.new(-120, 0, -260), 90, 55 },
		{ Vector3.new(40, 0, -300), 120, 70 },
		{ Vector3.new(180, 0, -220), 80, 45 },
		{ Vector3.new(-220, 0, -120), 70, 40 },
		{ Vector3.new(230, 0, -60), 100, 50 },
	} do
		makeMesa(folder, mesa[1], mesa[2], mesa[3])
	end

	-- A small herd of longhorns grazing on each side
	local coats = { Color3.fromRGB(140, 80, 40), Color3.fromRGB(235, 225, 210), Color3.fromRGB(100, 55, 30) }
	for _, cow in HERD do
		local cframe = CFrame.new(cow[1]) * CFrame.Angles(0, math.rad(cow[2]), 0)
		makeLonghorn(folder, cframe, coats[random:NextInteger(1, #coats)])
	end

	makeWindmill(folder, WINDMILL_POSITION)
	makeTexasFlag(folder, FLAG_POSITION)

	for _ = 1, 12 do
		makeCloud(folder, Vector3.new(random:NextNumber(-400, 400), random:NextNumber(110, 160), random:NextNumber(-300, 150)))
	end

	for i = 1, 3 do
		makeVulture(folder, Vector3.new(0, 55 + i * 6, -60), 25 + i * 8, i * 2)
	end

	for _ = 1, 4 do
		makeTumbleweed(folder)
	end

	folder.Parent = workspace

	-- Animate everything that moves, once per frame
	local t = 0
	RunService.RenderStepped:Connect(function(dt)
		t += dt
		for _, update in updaters do
			update(t, dt)
		end
	end)
end

return Scenery
