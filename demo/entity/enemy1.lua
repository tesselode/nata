local vector = require 'lib.vector'

return function(position)
	return {
		position = position - vector(16, 16)/2,
		size = vector(16, 16),
		velocity = vector(0, 64),
		removeWhenOffScreen = {
			bottom = true,
		},
		alliance = {
			evil = true,
			health = 1,
			damage = 10,
		},
		color = {1, 0, 0},
	}
end
