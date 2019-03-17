local score = {}

function score:init()
	self.score = 0
end

function score:die(e)
	if not self.pool.groups.score.hasEntity[e] then return false end
	self.score = self.score + e.score
end

function score:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('Score: ' .. self.score, 0, 64)
end

return score
