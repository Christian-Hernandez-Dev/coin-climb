-- One run of the course, start to finish:
--   - stepping on the "RunStart" pad starts the timer
--   - landing on the "Finish" pad stops it, records a best time, and tells the client to celebrate
--   - restarting (after celebrating, or from the Restart button) sends the player back to the beginning
-- Coins and upgrades are kept across runs.
--
-- Player attributes used: RunStart (server time the timer started, nil when not running),
-- LastTime and BestTime (seconds), Finished (true while celebrating).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Checkpoints = require(script.Parent.Checkpoints)

local RESTART_DELAY = 8 -- seconds of celebrating before heading back to the start
local RESTART_COOLDOWN = 1 -- ignore Restart presses closer together than this

local Run = {}

-- RemoteEvents go in ReplicatedStorage so both server and client can see them
local celebrate = Instance.new("RemoteEvent") -- server → client: "you finished, put on the show"
celebrate.Name = "Celebrate"
celebrate.Parent = ReplicatedStorage

local restartRequest = Instance.new("RemoteEvent") -- client → server: "I pressed Restart"
restartRequest.Name = "RestartRun"
restartRequest.Parent = ReplicatedStorage

local lastRestart = {} -- [player] = os.clock() of their last restart

local function restart(player)
	Checkpoints.reset(player)
	player:SetAttribute("RunStart", nil)
	player:SetAttribute("Finished", false)
	player:LoadCharacter() -- respawn now, at the start
end

local function onStartTouched(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if player and not player:GetAttribute("RunStart") and not player:GetAttribute("Finished") then
		-- Server time, so the client can show the same clock with workspace:GetServerTimeNow()
		player:SetAttribute("RunStart", workspace:GetServerTimeNow())
	end
end

local function onFinishTouched(part, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or player:GetAttribute("Finished") then
		return -- not a player, or already celebrating
	end
	player:SetAttribute("Finished", true)

	local time, newBest = nil, false
	local runStart = player:GetAttribute("RunStart")
	if runStart then
		time = workspace:GetServerTimeNow() - runStart
		local best = player:GetAttribute("BestTime")
		if not best or time < best then
			player:SetAttribute("BestTime", time)
			newBest = true
		end
		player:SetAttribute("LastTime", time)
		player:SetAttribute("RunStart", nil) -- stop the clock
	end

	celebrate:FireClient(player, part.Position, RESTART_DELAY, time, newBest)

	task.delay(RESTART_DELAY, function()
		if player.Parent then -- skip if they left the game while celebrating
			restart(player)
		end
	end)
end

local function onRestartRequest(player)
	if player:GetAttribute("Finished") then
		return -- already heading back after the celebration
	end
	local now = os.clock()
	if lastRestart[player] and now - lastRestart[player] < RESTART_COOLDOWN then
		return -- don't let button-mashing respawn over and over
	end
	lastRestart[player] = now
	restart(player)
end

local function forEachTagged(tag, callback)
	for _, part in CollectionService:GetTagged(tag) do
		callback(part)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

function Run.start()
	forEachTagged("RunStart", function(part)
		part.Touched:Connect(onStartTouched)
	end)
	forEachTagged("Finish", function(part)
		part.Touched:Connect(function(hit)
			onFinishTouched(part, hit)
		end)
	end)

	restartRequest.OnServerEvent:Connect(onRestartRequest)
	Players.PlayerRemoving:Connect(function(player)
		lastRestart[player] = nil
	end)
end

return Run
