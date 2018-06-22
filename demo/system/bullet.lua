local BulletSystem = {}

function BulletSystem:filter()
	return self.is.bullet
end

function BulletSystem:collide(other)
	if not other.is.bullet and other.is.evil ~= self.is.evil then
		self.dead = true
	end
end

return BulletSystem