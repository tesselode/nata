return {
	filter = {'points'},

	init = function(self)
		self.score = 0
	end,

	killed = function(self, entity)
		if self.hasEntity[entity] then
			self.score = self.score + entity.points
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.score)
	end,
}
