local vector = require 'lib.vector'

return function(position)
	return {
		position = position - vector(2, 4)/2,
		size = vector(2, 4),
		velocity = vector(0, 100),
		removeWhenOffScreen = {
			bottom = true,
		},
		alliance = {
			isBullet = true,
			evil = true,
			health = 1,
			damage = 5,
		},
		color = {1, 1, 0},
	}
end
