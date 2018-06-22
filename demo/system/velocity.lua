local VelocitySystem = {}

function VelocitySystem:filter()
	return self.x and self.y and self.vx and self.vy
end

function VelocitySystem:update(dt)
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	if self.stayOnScreen then
		if self.x < 0 then self.x = 0 end
		if self.x + self.w > love.graphics.getWidth() then
			self.x = love.graphics.getWidth() - self.w
		end
		if self.y < 0 then self.y = 0 end
		if self.y + self.h > love.graphics.getHeight() then
			self.y = love.graphics.getHeight() - self.h
		end
	end

	if self.removeWhenAboveScreen and self.y + self.h < 0 then
		self.dead = true
	end
	if self.removeWhenBelowScreen and self.y > love.graphics.getHeight() then
		self.dead = true
	end
end

return VelocitySystem