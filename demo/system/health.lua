local health = {}

function health:collide(e, other)
	if not self.pool.groups.health.hasEntity[e] then return false end
	if not self.pool.groups.health.hasEntity[other] then return false end
	if e.isBullet and other.isBullet then return false end
	if e.isEvil == other.isEvil then return false end
	e.health = e.health - other.damage
	if e.health <= 0 then
		e.dead = true
	end
end

return health
