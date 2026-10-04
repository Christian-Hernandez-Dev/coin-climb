-- Tracks the furthest checkpoint each player has reached and respawns them there.
-- A checkpoint is any part tagged "Checkpoint" with a "Checkpoint" number attribute.
-- The player's progress is stored as a "Checkpoint" attribute on the Player (0 = spawn).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local REACHED_COLOR = Color3.fromRGB(255, 200, 40) -- Lone Star gold
local UNREACHED_COLOR = Color3.fromRGB(200, 200, 200)

local Checkpoints = {}

local checkpointParts = {} -- [number] = part

local function onTouched(part, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	local number = part:GetAttribute("Checkpoint")
	-- Only move forward; landing on an earlier checkpoint shouldn't set you back
	if number > player:GetAttribute("Checkpoint") then
		player:SetAttribute("Checkpoint", number)
		local flag = part:FindFirstChild("Flag")
		if flag then
			flag.Color = REACHED_COLOR
		end
	end
end

local function setUpCheckpoint(part)
	checkpointParts[part:GetAttribute("Checkpoint")] = part
	part.Touched:Connect(function(hit)
		onTouched(part, hit)
	end)
end

local function onCharacterAdded(player, character)
	local part = checkpointParts[player:GetAttribute("Checkpoint")]
	if not part then
		return -- checkpoint 0: Roblox already spawned them at the SpawnLocation
	end

	character:WaitForChild("HumanoidRootPart")
	RunService.Heartbeat:Wait() -- let Roblox finish placing the character, or it overrides our move
	local top = part.Position.Y + part.Size.Y / 2
	character:PivotTo(CFrame.new(part.Position.X, top + 3, part.Position.Z))
end

local function onPlayerAdded(player)
	player:SetAttribute("Checkpoint", 0)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

-- Send a player back to square one: next respawn is at the SpawnLocation, and the flags go back to gray
function Checkpoints.reset(player)
	player:SetAttribute("Checkpoint", 0)
	for _, part in checkpointParts do
		local flag = part:FindFirstChild("Flag")
		if flag then
			flag.Color = UNREACHED_COLOR
		end
	end
end

function Checkpoints.start()
	for _, part in CollectionService:GetTagged("Checkpoint") do
		setUpCheckpoint(part)
	end
	CollectionService:GetInstanceAddedSignal("Checkpoint"):Connect(setUpCheckpoint)

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do -- players who joined before this ran
		onPlayerAdded(player)
	end
end

return Checkpoints
