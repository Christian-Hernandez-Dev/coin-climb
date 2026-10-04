-- Coin Climb: client entry point. Runs on each player's device.
-- Handles visuals, sound, and UI; game rules live on the server.
local Audio = require(script.Audio)
local Celebration = require(script.Celebration)
local CoinSpinner = require(script.CoinSpinner)
local RunHUD = require(script.RunHUD)
local Scenery = require(script.Scenery)
local ShopUI = require(script.ShopUI)

Scenery.build()
CoinSpinner.start()
Celebration.start()
Audio.start()
RunHUD.build()
ShopUI.build()
