local Object = require 'lib.classic'
local vector = require 'lib.vector'

local Player = Object:extend()

Player.size = vector(16, 16)
Player.color = {1, 1, 1}

function Player:new(position)
	self.position = position - self.size/2
	self.velocity = vector(100, 50)
end

return Player
