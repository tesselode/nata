local EnemyBullet = require 'entity.enemy-bullet'
local Object = require 'lib.classic'

local Enemy3 = Object:extend()

function Enemy3:new(entities, x, y)
	self.entities = entities
	self.is = {enemy = true, evil = true}
	self.x = x - 16
	self.y = y - 16
	self.w = 32
	self.h = 32
	self.vx = 0
	self.vy = 100
	self.removeWhenBelowScreen = true
	self.shoot = {
		bulletEntity = EnemyBullet,
		every = 1,
	}
	self.color = {0, 1, 0}
end

function Enemy3:update(dt)
	self.vx = 100 * math.sin(love.timer.getTime() * 3)
end

return Enemy3