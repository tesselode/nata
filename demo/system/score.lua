return {
	filter = {'points'},
	init = function(self)
		self.score = 0
	end,
	on = {
		killed = function(self, entity)
			self.score = self.score + entity.points
		end,
	},
	process = {
		draw = function(self)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(self.score)
		end,
	}
}
