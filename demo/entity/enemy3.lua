local Enemy = require 'entity.enemy'
local vector = require 'lib.vector'

local Enemy3 = Enemy:extend()

Enemy3.size = vector(24, 24)
Enemy3.color = {0, 1, 0}

function Enemy3:new(position)
	self.super.new(self, position)
	self.velocity = vector(0, 16)
	self.health = 8
	self.uptime = 0
end

function Enemy3:update(dt)
	self.uptime = self.uptime + dt
	self.position.x = self.position.x + 64 * math.sin(self.uptime * 2) * dt
end

return Enemy3
