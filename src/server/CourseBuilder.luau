-- Builds the course from CourseLayout into a "Course" folder in Workspace.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CourseLayout = require(ReplicatedStorage.Shared.CourseLayout)

local LAVA_COLOR = Color3.fromRGB(170, 20, 10) -- red-hot chili
local FLAG_COLOR = Color3.fromRGB(200, 200, 200) -- Checkpoints.luau turns it gold when reached
local COIN_COLOR = Color3.fromRGB(255, 200, 40)

local CourseBuilder = {}

local function makePart(info, parent)
	local part = Instance.new("Part")
	part.Name = info.name
	part.Size = info.size
	part.Position = info.position
	part.Anchored = true -- unanchored parts would fall
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- A flagpole standing on the back-left corner of a checkpoint platform
local function addFlag(platform)
	local top = platform.Position.Y + platform.Size.Y / 2
	local corner = platform.Position + Vector3.new(-platform.Size.X / 2 + 0.5, 0, -platform.Size.Z / 2 + 0.5)

	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Shape = Enum.PartType.Cylinder -- cylinders lie along X, so rotate to stand upright
	pole.Size = Vector3.new(6, 0.3, 0.3)
	pole.CFrame = CFrame.new(corner.X, top + 3, corner.Z) * CFrame.Angles(0, 0, math.rad(90))
	pole.Color = Color3.fromRGB(90, 90, 90)
	pole.Material = Enum.Material.Metal
	pole.Anchored = true
	pole.CanCollide = false
	pole.Parent = platform

	local flag = Instance.new("Part")
	flag.Name = "Flag"
	flag.Size = Vector3.new(2.5, 1.6, 0.1)
	flag.Position = Vector3.new(corner.X + 1.25, top + 5.1, corner.Z)
	flag.Color = FLAG_COLOR
	flag.Material = Enum.Material.Fabric
	flag.Anchored = true
	flag.CanCollide = false
	flag.Parent = platform
end

function CourseBuilder.build()
	-- Replace any old course (including hand-built platforms) so the layout file is the single source of truth
	local existing = workspace:FindFirstChild("Course")
	if existing then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "Course"

	for _, info in CourseLayout.platforms do
		local part = makePart(info, folder)
		part.Color = info.style.color
		part.Material = info.style.material

		if info.checkpoint then
			part:SetAttribute("Checkpoint", info.checkpoint)
			addFlag(part)
			CollectionService:AddTag(part, "Checkpoint") -- Checkpoints.luau handles every "Checkpoint"-tagged part
		end

		-- Run.luau handles both of these
		if info.runStart then
			CollectionService:AddTag(part, "RunStart")
		end
		if info.finish then
			CollectionService:AddTag(part, "Finish")
		end
	end

	local coinFolder = Instance.new("Folder")
	coinFolder.Name = "Coins"
	coinFolder.Parent = folder
	for i, info in CourseLayout.coins do
		local coin = Instance.new("Part")
		coin.Name = "Coin" .. i
		coin.Shape = Enum.PartType.Cylinder -- lies along X, so it stands on its edge like a coin
		local diameter = if (info.value or 1) > 1 then 4 else 2.6 -- bonus coins are bigger
		coin.Size = Vector3.new(0.4, diameter, diameter)
		coin.Position = info.position
		coin.Color = COIN_COLOR
		coin.Material = Enum.Material.Neon
		coin.Anchored = true
		coin.CanCollide = false -- pass through it, don't stand on it
		coin:SetAttribute("Value", info.value or 1)
		CollectionService:AddTag(coin, "Coin") -- Coins.luau (server) collects, CoinSpinner (client) spins
		coin.Parent = coinFolder
	end

	for _, info in CourseLayout.lava do
		local part = makePart(info, folder)
		part.Color = LAVA_COLOR
		part.Material = Enum.Material.Neon -- glows
		CollectionService:AddTag(part, "Lava") -- Lava.luau makes every "Lava"-tagged part deadly
	end

	folder.Parent = workspace
	return folder
end

return CourseBuilder
