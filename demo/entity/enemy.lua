local Object = require 'lib.classic'

local Enemy = Object:extend()

Enemy.removeWhenOffScreen = {
	bottom = true,
}

function Enemy:new(position)
	self.position = position - self.size/2
end

function Enemy:collide(other)
	if other:is(require 'entity.player-bullet') then
		self.health = self.health - 1
	end
end

return Enemy
