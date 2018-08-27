local Enemy = require 'entity.enemy'
local vector = require 'lib.vector'

local Enemy1 = Enemy:extend()

Enemy1.velocity = vector(0, 64)
Enemy1.size = vector(16, 16)
Enemy1.color = {1, 0, 0}

function Enemy1:new(position)
	self.super.new(self, position)
	self.health = 1
end

return Enemy1
