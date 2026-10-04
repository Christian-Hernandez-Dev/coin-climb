-- Turns seconds into "m:ss.s", e.g. 65.3 → "1:05.3". Shared so the timer and the banner match.
return function(seconds)
	local minutes = math.floor(seconds / 60)
	return string.format("%d:%04.1f", minutes, seconds - minutes * 60)
end
