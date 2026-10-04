-- Plays music and sound effects using the IDs in Shared/Sounds. Sounds set to 0 are skipped.
-- Sounds only this player hears, so it all lives on the client.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Sounds = require(ReplicatedStorage.Shared.Sounds)

local MUSIC_VOLUME = 0.3
local EFFECT_VOLUME = 0.6

local Audio = {}

local loaded = {} -- [name] = Sound

local function getSound(name)
	local id = Sounds[name]
	if not id or id == 0 then
		return nil
	end
	if not loaded[name] then
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = if name == "music" then MUSIC_VOLUME else EFFECT_VOLUME
		sound.Parent = SoundService
		loaded[name] = sound
	end
	return loaded[name]
end

function Audio.play(name)
	local sound = getSound(name)
	if sound then
		SoundService:PlayLocalSound(sound)
	end
end

local function startMusic()
	local music = getSound("music")
	if music then
		music.Looped = true
		music:Play()
	end
end

-- Coin sound: play whenever the coin count goes up (it goes down when shopping, which is silent)
local function watchCoins(player)
	local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
	local last = coins.Value
	coins.Changed:Connect(function(value)
		if value > last then
			Audio.play("coin")
		end
		last = value
	end)
end

-- Lava sound: the only way to die is the chili pit, so play it on every death
local function watchDeaths(player)
	local function onCharacter(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			Audio.play("lava")
		end)
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
end

function Audio.start()
	local player = Players.LocalPlayer
	startMusic()
	task.spawn(watchCoins, player) -- waits for leaderstats, so don't hold up the rest of startup
	watchDeaths(player)
end

return Audio
