local physical = {}

local defaultColor = {1, 1, 1}

function physical:update(dt)
	for _, e in ipairs(self.pool.groups.physical.entities) do
		-- apply velocity
		if e.vx then
			e.x = e.x + e.vx * dt
		end
		if e.vy then
			e.y = e.y + e.vy * dt
		end

		-- keep entities on screen
		if e.stayOnScreen then
			if e.x - e.r < 0 then e.x = e.r end
			if e.x + e.r > 800 then e.x = 800 - e.r end
			if e.y - e.r < 0 then e.y = e.r end
			if e.y + e.r > 600 then e.y = 600 - e.r end
		end

		-- delete off-screen entities
		if e.deleteWhenAboveScreen and e.y + e.r < 0 then
			e.dead = true
		end
		if e.deleteWhenBelowScreen and e.y - e.r > 600 then
			e.dead = true
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
