local input = require 'input'
local Object = require 'lib.classic'
local PlayerBullet = require 'entity.player-bullet'

local Player = Object:extend()

Player.speed = 400

function Player:new(entities, x, y)
	self.entities = entities
	self.is = {player = true}
	self.x = x - 16
	self.y = y - 16
	self.w = 32
	self.h = 32
	self.vx = 0
	self.vy = 0
	self.stayOnScreen = true
	self.shoot = {
		bulletEntity = PlayerBullet,
		reloadTime = 1/6,
	}
end

function Player:update(dt)
	local moveX, moveY = input:get 'move'
	self.vx = self.speed * moveX
	self.vy = self.speed * moveY

	if input:down 'action' then
		self.entities:callOn(self, 'shoot')
	end
end

function Player:collide(other)
	if other.is.evil then
		self.dead = true
	end
end

return Player