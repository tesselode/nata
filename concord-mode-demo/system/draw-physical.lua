local Position = require 'component.position'
local Size = require 'component.size'

local DrawPhysical = {}

function DrawPhysical:draw()
	for _, e in ipairs(self.pool.groups.physical.entities) do
		love.graphics.rectangle('fill', e[Position].x, e[Position].y,
			e[Size].x, e[Size].y)
	end
end

return DrawPhysical
