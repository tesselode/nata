local EnemySystem = {}

function EnemySystem:filter()
	return self.is.enemy
end

function EnemySystem:collide(other)
	if not other.is.evil then
		self.dead = true
	end
end

return EnemySystem