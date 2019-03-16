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
	self.r = 32
	self.vx = 0
	self.vy = 0
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
	self.vx = inputX * 200
	self.vy = inputY * 200
end

return Player
