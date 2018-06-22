local function bbox(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		   x2 < x1+w1 and
		   y1 < y2+h2 and
		   y2 < y1+h1
end

local CollisionSystem = {}

function CollisionSystem:filter()
	return self.x and self.y and self.w and self.h
end

function CollisionSystem:update(dt)
	for _, other in ipairs(self.entities:get()) do
		if other ~= self and bbox(self.x, self.y, self.w, self.h,
				other.x, other.y, other.w, other.h) then
			self.entities:callOn(self, 'collide', other)
		end
	end
end

return CollisionSystem