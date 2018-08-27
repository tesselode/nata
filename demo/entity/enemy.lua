local Object = require 'lib.classic'

local Enemy = Object:extend()

Enemy.removeWhenOffScreen = {
	bottom = true,
}

function Enemy:new(position)
	self.position = position - self.size/2
end

return Enemy
