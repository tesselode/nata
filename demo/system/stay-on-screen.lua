local constant = require 'constant'

return {
	filter = {'position', 'size', 'stayOnScreen'},

	update = function(self, dt)
		for _, entity in ipairs(self.entities) do
			if entity.position.x < 0 then
				entity.position.x = 0
			end
			if entity.position.x + entity.size.x > constant.screenSize.x then
				entity.position.x = constant.screenSize.x - entity.size.x
			end
			if entity.position.y < 0 then
				entity.position.y = 0
			end
			if entity.position.y + entity.size.y > constant.screenSize.y then
				entity.position.y = constant.screenSize.y - entity.size.y
			end
		end
	end,
}
