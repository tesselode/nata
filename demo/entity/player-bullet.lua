local vector = require 'lib.vector'

return function(position)
	return {
		position = position - vector(2, 4)/2,
		size = vector(2, 4),
		velocity = vector(0, -200),
		removeWhenOffScreen = {
			top = true,
		},
		alliance = {
			isBullet = true,
			health = 1,
			damage = 1,
		},
		color = {1, 1, 1},
	}
end
