local anim8 = require 'lib.anim8'
local image = require 'image'
local input = require 'input'
local Object = require 'lib.classic'
local vector = require 'lib.vector'

local Player = Object:extend()

Player.acceleration = 1600
Player.friction = 10
Player.size = vector(16, 16)
Player.stayOnScreen = true

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
	local g = anim8.newGrid(16, 24, image.ship:getWidth(), image.ship:getHeight())
	self.sprite = {
		image = image.ship,
		animations = {
			anim8.newAnimation(g(1, 1, 1, 2), 1/6),
			anim8.newAnimation(g(2, 1, 2, 2), 1/6),
			anim8.newAnimation(g(3, 1, 3, 2), 1/6),
			anim8.newAnimation(g(4, 1, 4, 2), 1/6),
			anim8.newAnimation(g(5, 1, 5, 2), 1/6),
		},
		current = function()
			return self.velocity.x < -64 and 1
				or self.velocity.x < -8 and 2
				or self.velocity.x > 64 and 5
				or self.velocity.x > 8 and 4
				or 3
		end
	}
end

function Player:update(dt)
	self.velocity = self.velocity + self.acceleration * dt * vector(input:get 'move')
	self.velocity = self.velocity - self.velocity * self.friction * dt
	self.shoot.enabled = input:down 'primary'
end

return Player
