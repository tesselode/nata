local DrawSystem = {}

function DrawSystem:filter()
	return self.x and self.y and self.w and self.h
end

function DrawSystem:draw()
	love.graphics.setColor(self.color or {1, 1, 1})
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

return DrawSystem