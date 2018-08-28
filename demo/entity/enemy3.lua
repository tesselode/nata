local anim8 = require 'lib.anim8'
local image = require 'image'
local vector = require 'lib.vector'

local g = anim8.newGrid(image.enemyBig:getWidth()/2, image.enemyBig:getHeight(),
	image.enemyBig:getWidth(), image.enemyBig:getHeight())

return function(position)
	return {
		position = position - vector(24, 24)/2,
		size = vector(20, 20),
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
		sprite = {
			image = image.enemyBig,
			animations = {
				anim8.newAnimation(g('1-2', 1), 1/6),
			},
			current = 1,
			offset = vector(6, 10),
		},
	}
end
