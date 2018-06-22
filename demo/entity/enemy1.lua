return function(entities, x, y)
	return {
		entities = entities,
		is = {enemy = true, evil = true},
		x = x - 16,
		y = y - 16,
		w = 32,
		h = 32,
		vx = 0,
		vy = 200,
		removeWhenBelowScreen = true,
		color = {1, 0, 0},
	}
end