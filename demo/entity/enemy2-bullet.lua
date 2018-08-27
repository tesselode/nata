local Object = require 'lib.classic'
local vector = require 'lib.vector'

local Enemy2Bullet = Object:extend()

Enemy2Bullet.size = vector(2, 4)
Enemy2Bullet.velocity = vector(0, 100)
Enemy2Bullet.removeWhenOffScreen = {
	bottom = true,
}
Enemy2Bullet.color = {1, 1, 0}

function Enemy2Bullet:new(position)
	self.position = position - self.size/2
	self.alliance = {
		evil = true,
		health = 1,
		damage = 5,
	}
end

return Enemy2Bullet
