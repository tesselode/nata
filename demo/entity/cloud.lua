local image = require 'image'
local vector = require 'lib.vector'

return function()
	return {
		depth = 10 + love.math.random(),
		position = vector(0, -128),
		velocity = vector(0, 16),
		removeWhenOffScreen = {
			bottom = true,
		},
		sprite = {
			image = image.clouds,
		}
	}
end
