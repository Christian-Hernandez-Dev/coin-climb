-- Sound and music IDs. Leave a sound at 0 and it simply stays silent.
--
-- To add one: in Studio open the Toolbox → Creator Store → Audio, search (e.g. "country",
-- "banjo", "coin", "firework"), preview, then right-click a result → "Copy Asset ID" and paste it here.

return {
	music = 138352828771722, -- background music, loops the whole time ("Dusty Western Sunset Ride")
	coin = 0, -- picking up a coin
	purchase = 0, -- buying an upgrade
	lava = 0, -- falling into the chili
	finish = 0, -- fanfare when reaching the finish
	firework = 0, -- each firework burst
}
