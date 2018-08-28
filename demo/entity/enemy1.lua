local anim8 = require 'lib.anim8'
local image = require 'image'
local vector = require 'lib.vector'

local g = anim8.newGrid(image.enemyMedium:getWidth()/2, image.enemyMedium:getHeight(),
	image.enemyMedium:getWidth(), image.enemyMedium:getHeight())

return function(position)
	return {
		position = position - vector(16, 16)/2,
		size = vector(24, 12),
		velocity = vector(0, 64),
		removeWhenOffScreen = {
			bottom = true,
		},
		alliance = {
			evil = true,
			health = 1,
			damage = 10,
		},
		sprite = {
			image = image.enemyMedium,
			animations = {
				anim8.newAnimation(g('1-2', 1), 1/6),
			},
			current = 1,
			offset = vector(4, 3),
		},
	}
end
