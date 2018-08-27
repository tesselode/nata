local constant = require 'constant'
local Enemy1 = require 'entity.enemy1'
local Enemy2 = require 'entity.enemy2'
local Enemy3 = require 'entity.enemy3'
local nata = require 'lib.nata'
local Player = require 'entity.player'
local timer = require 'lib.timer'
local vector = require 'lib.vector'

local function removeCondition(entity)
	return entity.dead
end

local game = {}

function game:enter()
	self.timer = timer.new()
	self.entities = nata.new {
		nata.oop,
		require 'system.move',
		require 'system.wiggle',
		require 'system.stay-on-screen',
		require 'system.remove-when-off-screen',
		require 'system.collide',
		require 'system.alliance',
		require 'system.shoot',
		require 'system.draw',
	}
	self.entities:queue(Player(constant.screenSize / 2))
	self.spawnSpeed = 1
	self.timer:every(1, function()
		self.entities:queue(Enemy1(vector(love.math.random(constant.screenSize.x), -16)))
	end)
	self.timer:every(1.5, function()
		self.entities:queue(Enemy2(vector(love.math.random(constant.screenSize.x), -16)))
	end)
	self.timer:every(4.5, function()
		self.entities:queue(Enemy3(vector(love.math.random(constant.screenSize.x), -16)))
	end)
end

function game:update(dt)
	self.spawnSpeed = self.spawnSpeed + 1/30 * dt
	self.timer:update(self.spawnSpeed * dt)
	self.entities:remove(removeCondition)
	self.entities:flush()
	self.entities:process('update', dt)
end

function game:draw()
	self.entities:process('draw')
	self.entities:process('postDraw')
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(#self.entities.entities)
end

return game
