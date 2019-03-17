local PlayerBullet = require 'entity.player-bullet'

local Player = {}
Player.__index = Player

setmetatable(Player, {
	__call = function(self, ...)
		local player = setmetatable({}, Player)
		player:new(...)
		return player
	end,
})

function Player:new(x, y)
	self.x = x
	self.y = y
	self.r = 16
	self.vx = 0
	self.vy = 0
	self.stayOnScreen = true
	self.shoot = {
		entity = PlayerBullet,
		reloadTime = 1/6,
	}
	self.health = 20
	self.damage = 3
end

function Player:update(dt)
	local inputX, inputY = 0, 0
	if love.keyboard.isDown 'left' then
		inputX = inputX - 1
	end
	if love.keyboard.isDown 'right' then
		inputX = inputX + 1
	end
	if love.keyboard.isDown 'up' then
		inputY = inputY - 1
	end
	if love.keyboard.isDown 'down' then
		inputY = inputY + 1
	end
	self.vx = inputX * 300
	self.vy = inputY * 300

	self.shoot.disabled = not love.keyboard.isDown 'z'
end

function Player:draw()
	love.graphics.print('Health: ' .. self.health, 0, 80)
end

return Player
