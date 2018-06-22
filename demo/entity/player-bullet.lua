return function(entities, x, y)
	return {
		entities = entities,
		is = {bullet = true},
		x = x - 4,
		y = y - 4,
		w = 8,
		h = 8,
		vx = 0,
		vy = -800,
		removeWhenAboveScreen = true,
	}
end