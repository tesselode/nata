return function(entities, x, y)
	return {
		entities = entities,
		is = {bullet = true, evil = true},
		x = x - 4,
		y = y - 4,
		w = 8,
		h = 8,
		vx = 0,
		vy = 500,
		removeWhenBelowScreen = true,
		color = {1, 0, 0},
	}
end