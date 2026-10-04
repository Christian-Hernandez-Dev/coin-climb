-- Coin Climb: server entry point. Runs once on the server when the game starts.
local Checkpoints = require(script.Checkpoints)
local Coins = require(script.Coins)
local CourseBuilder = require(script.CourseBuilder)
local Lava = require(script.Lava)
local PlayerData = require(script.PlayerData)
local Run = require(script.Run)
local Shop = require(script.Shop)
local Theme = require(script.Theme)

-- Start these before building, so they catch the tagged parts as they're added
Lava.start()
Checkpoints.start()
Coins.start()
Run.start()
Shop.start()
PlayerData.start() -- after Coins and Shop, which set up the values it loads into

Theme.apply()
CourseBuilder.build()
print("Coin Climb server started")
