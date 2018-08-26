local Object = require 'lib.classic'
local vector = require 'lib.vector'

local Enemy = Object:extend()

Enemy.velocity = vector(0, 16)
Enemy.size = vector(16, 16)
Enemy.removeWhenOffScreen = {
	bottom = true,
}
Enemy.color = {1, 0, 0}

function Enemy:new(position)
	self.position = position - self.size/2
end

function Enemy:collide(other)
	if other:is(require 'entity.player-bullet') then
		self.dead = true
	end
end

return Enemy
