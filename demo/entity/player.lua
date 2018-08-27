local constant = require 'constant'
local input = require 'input'
local Object = require 'lib.classic'
local vector = require 'lib.vector'

local Player = Object:extend()

Player.acceleration = 1600
Player.friction = 10
Player.size = vector(16, 16)
Player.stayOnScreen = true
Player.color = {1, 1, 1}

function Player:new(position)
	self.position = position - self.size/2
	self.velocity = vector()
	self.shoot = {
		entity = require 'entity.player-bullet',
		reloadTime = 1/8,
		enabled = false,
	}
	self.alliance = {
		health = 100,
		damage = 100,
	}
end

function Player:update(dt)
	self.velocity = self.velocity + self.acceleration * dt * vector(input:get 'move')
	self.velocity = self.velocity - self.velocity * self.friction * dt
	self.shoot.enabled = input:down 'primary'
end

function Player:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.arc('fill', 'pie', constant.screenSize.x - 10, 10,
		8, 0, 2 * math.pi * (self.alliance.health / 100), 64)
end

return Player
