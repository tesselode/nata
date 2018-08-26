return {
	filter = {'position', 'size', 'shoot'},
	on = {
		add = function(self, entity)
			if self.hasEntity[entity] then
				entity.shoot.reloadTimer = 0
			end
		end,
	},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				entity.shoot.reloadTimer = entity.shoot.reloadTimer - dt
				if entity.shoot.enabled and entity.shoot.reloadTimer <= 0 then
					self:queue(entity.shoot.entity(entity.position + entity.size/2))
					entity.shoot.reloadTimer = entity.shoot.reloadTime
				end
			end
		end
	}
}
