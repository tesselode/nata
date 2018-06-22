local EnemyBullet = require 'entity.enemy-bullet'

return function(entities, x, y)
	return {
		entities = entities,
		is = {enemy = true, evil = true},
		x = x - 16,
		y = y - 16,
		w = 32,
		h = 32,
		vx = -100 + love.math.random(200),
		vy = 300,
		removeWhenBelowScreen = true,
		shoot = {
			bulletEntity = EnemyBullet,
			every = 2/3,
		},
		color = {1, 1, 0},
	}
end