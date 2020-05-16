--[[
	this system enables shooting behavior for entities.
	entities can specify a bullet entity to spawn and a cooldown time.
]]

local shoot = {}

function shoot:add(groupName, e)
	-- initialize entities that can shoot with a reload timer
	if not self.pool 'shoot'.has[e] then return false end
	e.shoot.reloadTimer = 0
end

function shoot:update(dt)
	for _, e in ipairs(self.pool 'shoot'.entities) do
		if e.shoot.reloadTimer > 0 then
			e.shoot.reloadTimer = e.shoot.reloadTimer - dt
		end
		while e.shoot.reloadTimer <= 0 do
			if e.shoot.disabled then
				e.shoot.reloadTimer = 0
				break
			else
				e.shoot.reloadTimer = e.shoot.reloadTimer + e.shoot.reloadTime
				self.pool:queue(e.shoot.entity(e.x, e.y))
			end
		end
	end
end

return shoot
