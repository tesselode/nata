--[[
	this system manages the health for entities. if an
	entity runs out of health, it's marked for removal.
]]

local health = {}

function health:collide(e, other)
	--[[
		make sure both entities have health. otherwise, this
		system shouldn't operate on them.
	]]
	if not self.pool 'health'.has(e) then return false end
	if not self.pool 'health'.has(other) then return false end
	-- bullets shouldn't damage each other
	if e.isBullet and other.isBullet then return false end
	-- two entities that are both good or both evil shouldn't damage each other
	if e.isEvil == other.isEvil then return false end
	-- decrease health and kill the entity if health reaches 0
	e.health = e.health - other.damage
	if e.health <= 0 then
		self.pool:emit('die', e) -- emit a "die" event that other systems can respond to
		e.dead = true
	end
end

return health
