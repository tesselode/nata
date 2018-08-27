local Object = require 'lib.classic'
local vector = require 'lib.vector'

local PlayerBullet = Object:extend()

PlayerBullet.size = vector(2, 4)
PlayerBullet.velocity = vector(0, -200)
PlayerBullet.removeWhenOffScreen = {
	top = true,
}
PlayerBullet.color = {1, 1, 1}

function PlayerBullet:new(position)
	self.position = position - self.size/2
	self.alliance = {
		health = 1,
		damage = 1,
	}
end

return PlayerBullet
