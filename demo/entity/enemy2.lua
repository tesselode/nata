local anim8 = require 'lib.anim8'
local image = require 'image'
local vector = require 'lib.vector'

local g = anim8.newGrid(image.enemySmall:getWidth()/2, image.enemySmall:getHeight(),
	image.enemySmall:getWidth(), image.enemySmall:getHeight())

return function(position)
	return {
		depth = love.math.random(),
		position = position - vector(12, 12)/2,
		size = vector(12, 8),
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
		sprite = {
			image = image.enemySmall,
			animations = {
				anim8.newAnimation(g('1-2', 1), 1/6),
			},
			current = 1,
			offset = vector(2, 4),
		},
	}
end
