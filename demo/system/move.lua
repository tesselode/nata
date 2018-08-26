return {
	filter = {'position', 'velocity'},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				entity.position = entity.position + entity.velocity * dt
			end
		end,
	}
}
