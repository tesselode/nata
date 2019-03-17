local EnemyBullet = require 'entity.enemy-bullet'

return function(x, y)
	return {
		color = {1, 0, 0},
		x = x,
		y = y,
		r = 16,
		vx = love.math.random(-100, 100),
		vy = 200,
		deleteWhenBelowScreen = true,
		shoot = {
			entity = EnemyBullet,
			reloadTime = 1,
		}
	}
end
