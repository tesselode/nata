--[[
	this system doesn't operate on any entities directly,
	but it does spawn enemies at regular intervals.
]]

local Enemy1 = require 'entity.enemy1'
local Enemy2 = require 'entity.enemy2'

local spawn = {}

function spawn:init()
	self.enemy1SpawnTime = 1
	self.enemy1SpawnTimer = self.enemy1SpawnTime
	self.enemy2SpawnTime = 5
	self.enemy2SpawnTimer = 15
end

function spawn:update(dt)
	self.enemy1SpawnTime = self.enemy1SpawnTime - self.enemy1SpawnTime * .025 * dt
	self.enemy1SpawnTimer = self.enemy1SpawnTimer - dt
	while self.enemy1SpawnTimer <= 0 do
		self.enemy1SpawnTimer = self.enemy1SpawnTimer + self.enemy1SpawnTime
		self.pool:queue(Enemy1(love.math.random(800), -50))
	end

	self.enemy2SpawnTime = self.enemy2SpawnTime - self.enemy2SpawnTime * .025 * dt
	self.enemy2SpawnTimer = self.enemy2SpawnTimer - dt
	while self.enemy2SpawnTimer <= 0 do
		self.enemy2SpawnTimer = self.enemy2SpawnTimer + self.enemy2SpawnTime
		self.pool:queue(Enemy2(love.math.random(800), -50))
	end
end

return spawn
