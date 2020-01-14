local Position = require 'component.position'
local Velocity = require 'component.velocity'

local VelocitySystem = {}

function VelocitySystem:update(dt)
	for _, e in ipairs(self.pool.groups.velocity.entities) do
		e[Position].x = e[Position].x + e[Velocity].x * dt
		e[Position].y = e[Position].y + e[Velocity].y * dt
	end
end

return VelocitySystem
