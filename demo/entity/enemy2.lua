local vector = require 'lib.vector'

return function(position)
	return {
		position = position - vector(12, 12)/2,
		size = vector(12, 12),
		velocity = vector(love.math.random(-16, 16), 32),
		removeWhenOffScreen = {
			bottom = true,
		},
		shoot = {
			entity = require 'entity.enemy2-bullet',
			reloadTime = 1,
			enabled = true,
		},
		alliance = {
			evil = true,
			health = 1,
			damage = 15,
		},
		color = {1, 1, 0},
	}
end
