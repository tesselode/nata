local function bbox(ax, ay, aw, ah, bx, by, bw, bh)
	if ax > bx + bw then return false end
	if ay > by + bh then return false end
	if bx > ax + aw then return false end
	if by > ay + ah then return false end
	return true
end

return {
	filter = {'position', 'size'},

	update = function(self, dt)
		for i = 1, #self.entities - 1 do
			for j = i + 1, #self.entities do
				local a = self.entities[i]
				local b = self.entities[j]
				if bbox(a.position.x, a.position.y, a.size.x, a.size.y,
						b.position.x, b.position.y, b.size.x, b.size.y) then
					self:call('collide', a, b)
					self:call('collide', b, a)
				end
			end
		end
	end,
}
