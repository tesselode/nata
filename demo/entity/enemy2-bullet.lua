local anim8 = require 'lib.anim8'
local image = require 'image'
local vector = require 'lib.vector'

local g = anim8.newGrid(14, 14, image.laserBolts:getWidth(), image.laserBolts:getHeight(), 2, 2)

return function(position)
	return {
		depth = love.math.random(),
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
		sprite = {
			image = image.laserBolts,
			animations = {
				anim8.newAnimation(g('1-2', 1), 1/6)
			},
			current = 1,
			offset = vector(6, 4),
		},
	}
end
