return {
	filter = {'position', 'sprite'},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				for _, animation in pairs(entity.sprite.animations) do
					animation:update(dt)
				end
			end
		end,
		draw = function(self)
			for _, entity in ipairs(self.entities) do
				local current = type(entity.sprite.current) == 'function' and entity.sprite.current() or entity.sprite.current
				love.graphics.setColor(1, 1, 1)
				local ox, oy = 0, 0
				if entity.sprite.offset then
					ox, oy = entity.sprite.offset:unpack()
				end
				entity.sprite.animations[current]:draw(entity.sprite.image, entity.position.x, entity.position.y, 0, 1, 1, ox, oy)
			end
		end,
	}
}
