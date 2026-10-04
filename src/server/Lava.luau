-- Makes every part tagged "Lava" defeat any character that touches it.
-- Tags mean new lava parts work automatically, whether built from code or tagged by hand in Studio.

local CollectionService = game:GetService("CollectionService")

local Lava = {}

local function onTouched(hit)
	-- hit is the body part that touched the lava; its parent is the character model
	local character = hit.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0 -- the player respawns automatically
	end
end

local function setUpLava(part)
	part.Touched:Connect(onTouched)
end

function Lava.start()
	for _, part in CollectionService:GetTagged("Lava") do
		setUpLava(part)
	end
	-- Catch lava parts added later
	CollectionService:GetInstanceAddedSignal("Lava"):Connect(setUpLava)
end

return Lava
