return {
	filter = {'position', 'sprite'},

	sort = function(a, b)
		return a.depth > b.depth
	end,

	update = function(self, dt)
		for _, entity in ipairs(self.entities) do
			if entity.sprite.animations then
				for _, animation in pairs(entity.sprite.animations) do
					animation:update(dt)
				end
			end
		end
	end,

	draw = function(self)
		for _, entity in ipairs(self.entities) do
			local s = entity.sprite
			local ox, oy = 0, 0
			if s.offset then
				ox, oy = s.offset:unpack()
			end
			love.graphics.setColor(1, 1, 1)
			if s.animations then
				local current = type(s.current) == 'function' and s.current() or s.current
				s.animations[current]:draw(s.image, entity.position.x, entity.position.y, 0, 1, 1, ox, oy)
			else
				love.graphics.draw(s.image, entity.position.x, entity.position.y, 0, 1, 1, ox, oy)
			end
		end
	end,
}
