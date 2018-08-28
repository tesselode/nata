local explosion = require 'entity.explosion'

return {
	filter = {'alliance'},
	on = {
		collide = function(self, entity, other)
			if entity.alliance.isBullet and other.alliance.isBullet then
				return
			end
			if entity.alliance.evil == other.alliance.evil then
				return
			end
			entity.alliance.health = entity.alliance.health - other.alliance.damage
			if entity.alliance.health <= 0 then
				entity.dead = true
				if not entity.alliance.isBullet then
					self:queue(explosion(entity.position + entity.size/2))
				end
			end
		end,
	}
}
