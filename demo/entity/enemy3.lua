local vector = require 'lib.vector'

return function(position)
	return {
		position = position - vector(24, 24)/2,
		size = vector(24, 24),
		velocity = vector(0, 16),
		wiggle = {
			amount = 64,
			speed = 2,
		},
		removeWhenOffScreen = {
			bottom = true,
		},
		alliance = {
			evil = true,
			health = 5,
			damage = 30,
		},
		color = {0, 1, 0},
	}
end
