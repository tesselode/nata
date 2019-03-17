local EnemyBullet = require 'entity.enemy-bullet'

return function(x, y)
	return {
		color = {0, 1, 0},
		x = x,
		y = y,
		r = 32,
		vx = 0,
		vy = 100,
		deleteWhenBelowScreen = true,
		shoot = {
			entity = EnemyBullet,
			reloadTime = 2,
		},
		health = 5,
		damage = 1,
		isEvil = true,
	}
end
