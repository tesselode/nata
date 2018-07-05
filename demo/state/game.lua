local Enemy1 = require 'entity.enemy1'
local Enemy2 = require 'entity.enemy2'
local Enemy3 = require 'entity.enemy3'
local nata = require 'lib.nata'
local Player = require 'entity.player'
local timer = require 'lib.timer'

local game = {}

function game:enter()
	self.timer = timer.new()
	self.entities = nata.new {
		require 'system.timer',
		nata.oop(),
		require 'system.enemy',
		require 'system.bullet',
		require 'system.velocity',
		require 'system.collision',
		require 'system.shoot',
		require 'system.draw',
	}
	self.entities:queue(Player(self.entities, 400, 500))
	self.timer:every(1, function()
		self.entities:queue(Enemy1(self.entities, 50 + love.math.random(700), -50))
	end)
	self.timer:after(10, function()
		self.timer:every(1.5, function()
			self.entities:queue(Enemy2(self.entities, 50 + love.math.random(700), -50))
		end)
	end)
	self.timer:after(20, function()
		self.timer:every(2, function()
			self.entities:queue(Enemy3(self.entities, 50 + love.math.random(700), -50))
		end)
	end)
	self.spawnSpeed = 1
end

function game:update(dt)
	self.spawnSpeed = self.spawnSpeed + .01 * dt
	self.timer:update(dt * self.spawnSpeed)
	self.entities:flush()
	self.entities:call('update', dt)
	self.entities:remove(function(entity) return entity.dead end)
end

function game:draw()
	self.entities:call 'draw'
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(love.timer.getFPS())
end

return game
