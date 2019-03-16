local physical = {}

local defaultColor = {1, 1, 1}

function physical:update(dt)
	for _, e in ipairs(self.pool.groups.physical.entities) do
		if e.vx then
			e.x = e.x + e.vx * dt
		end
		if e.vy then
			e.y = e.y + e.vy * dt
		end
	end
end

function physical:draw()
	for _, e in ipairs(self.pool.groups.physical.entities) do
		love.graphics.setColor(e.color or defaultColor)
		love.graphics.circle('fill', e.x, e.y, e.r, e.segments or 64)
	end
end

return physical
