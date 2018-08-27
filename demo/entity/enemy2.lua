local Enemy = require 'entity.enemy'
local vector = require 'lib.vector'

local Enemy2 = Enemy:extend()

Enemy2.size = vector(12, 12)
Enemy2.color = {1, 1, 0}

function Enemy2:new(position)
	self.super.new(self, position)
	self.velocity = vector(love.math.random(-16, 16), 32)
	self.shoot = {
		entity = require 'entity.enemy2-bullet',
		reloadTime = 1,
		enabled = true,
	}
	self.alliance = {
		evil = true,
		health = 1,
		damage = 15,
	}
end

return Enemy2
