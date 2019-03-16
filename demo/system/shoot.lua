local shoot = {}

function shoot:add(groupName, e)
	if groupName ~= 'shoot' then return false end
	e.shoot.reloadTimer = 0
end

function shoot:update(dt)
	for _, e in ipairs(self.pool.groups.shoot.entities) do
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
