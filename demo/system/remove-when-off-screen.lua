local constant = require 'constant'

return {
	filter = {'position', 'size', 'removeWhenOffScreen'},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				if entity.removeWhenOffScreen.left and entity.position.x + entity.size.x < 0 then
					entity.dead = true
				end
				if entity.removeWhenOffScreen.right and entity.position.x > constant.screenSize.x then
					entity.dead = true
				end
				if entity.removeWhenOffScreen.top and entity.position.y + entity.size.y < 0 then
					entity.dead = true
				end
				if entity.removeWhenOffScreen.bottom and entity.position.y > constant.screenSize.y then
					entity.dead = true
				end
			end
		end,
	}
}
