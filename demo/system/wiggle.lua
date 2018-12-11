return {
	filter = {'wiggle'},

	add = function(self, entity)
		entity.wiggle.time = 0
	end,

	update = function(self, dt)
		for _, entity in ipairs(self.entities) do
			local w = entity.wiggle
			w.time = w.time + dt
			local dx = w.amount * math.sin(w.time * w.speed)
			entity.position.x = entity.position.x + dx * dt
		end
	end,
}
