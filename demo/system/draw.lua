return {
	filter = {'position', 'size', 'color'},
	process = {
		draw = function(self)
			for _, entity in ipairs(self.entities) do
				love.graphics.setColor(entity.color)
				love.graphics.rectangle('fill', entity.position.x,
					entity.position.y, entity.size.x, entity.size.y)
			end
		end,
	},
}
