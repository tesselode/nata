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
end

function PlayerBullet:collide(other)
	if other:is(require 'entity.enemy') then
		self.dead = true
	end
end

return PlayerBullet
