return {
	filter = {'health'},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				if entity.health <= 0 then
					entity.dead = true
				end
			end
		end,
	}
}
