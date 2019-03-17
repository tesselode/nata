local Enemy1 = require 'entity.enemy1'

local spawn = {}

function spawn:init()
	self.enemy1SpawnTime = 1
	self.enemy1SpawnTimer = self.enemy1SpawnTime
end

function spawn:update(dt)
	self.enemy1SpawnTime = self.enemy1SpawnTime - self.enemy1SpawnTime * .025 * dt
	self.enemy1SpawnTimer = self.enemy1SpawnTimer - dt
	while self.enemy1SpawnTimer <= 0 do
		self.enemy1SpawnTimer = self.enemy1SpawnTimer + self.enemy1SpawnTime
		self.pool:queue(Enemy1(love.math.random(800), -50))
	end
end

return spawn
