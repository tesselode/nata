return {
	filter = {'alliance'},
	on = {
		collide = function(self, entity, other)
			if entity.alliance.evil ~= other.alliance.evil then
				entity.alliance.health = entity.alliance.health - other.alliance.damage
				if entity.alliance.health <= 0 then
					entity.dead = true
				end
			end
		end,
	}
}
