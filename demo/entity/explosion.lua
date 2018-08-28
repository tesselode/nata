local anim8 = require 'lib.anim8'
local image = require 'image'
local vector = require 'lib.vector'

local g = anim8.newGrid(image.explosion:getWidth()/5, image.explosion:getHeight(),
	image.explosion:getWidth(), image.explosion:getHeight())

return function(position)
	local explosion
	explosion = {
		depth = love.math.random(),
		position = position,
		sprite = {
			image = image.explosion,
			animations = {
				anim8.newAnimation(g('1-5', 1), 1/12, function()
					explosion.sprite.animations[1]:gotoFrame(5)
					explosion.sprite.animations[1]:pause()
					explosion.dead = true
				end),
			},
			current = 1,
			offset = vector(8, 8),
		}
	}
	return explosion
end
